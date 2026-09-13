# q14 — A container is being OOMKilled · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `prod` 의 Deployment `resizer` 가 계속 재시작한다. `kubectl get pods` 에서
`RESTARTS` 가 올라가고 파드가 `Running` 과 `CrashLoopBackOff` 를 오간다. 이미지는 정상이고
스테이징에서는 잘 돌았다.

1. 컨테이너가 스스로 크래시한 것이 아니라 메모리 때문에 죽는 것임을 확인한다. 어떤 필드를 읽고
   어떤 종료 코드를 기대하는지 적는다.
2. 컨테이너의 현재 메모리 request와 limit, 그리고 실제 사용량을 보고한다.
3. 노드에 여유 메모리가 있는데도 파드가 죽은 이유를 한 줄로 설명한다.
4. 죽지 않을 가장 작은 반올림 값으로 limit을 올린다. request는 파드가 여전히 스케줄될 수 있는
   값으로 유지하고, 재시작이 멈추는지 확인한다.
5. 변경 전과 후의 컨테이너 QoS 클래스를 `/opt/course/q14/qos.txt` 에 쓴다.

## 모범 풀이

**1) OOM 확정** — `describe` 가 아니라 `lastState` 를 봐야 합니다.

```bash
kubectl -n prod get pods
POD=$(kubectl -n prod get pod -l app=resizer -o name | head -1)

kubectl -n prod get $POD -o jsonpath='{.status.containerStatuses[0].lastState.terminated}{"\n"}'
# {"containerID":"...","exitCode":137,"finishedAt":"...","reason":"OOMKilled","startedAt":"..."}

kubectl -n prod describe $POD | grep -A5 'Last State'
#     Last State:     Terminated
#       Reason:       OOMKilled
#       Exit Code:    137
```

`lastState.terminated.reason: OOMKilled` 와 **exit code 137** 이 결정적 증거입니다.
137 = 128 + 9 (SIGKILL). 애플리케이션이 스스로 죽으면 보통 1, 2 또는 그 앱 고유 코드가 나옵니다.
`state` 는 현재 상태이고 `lastState` 는 이전 종료 상태라서, 재시작 원인을 찾을 때는 항상
`lastState` 입니다. 파드가 지금 Running이면 `state.running` 만 보고 "정상"이라고 오판하기 쉽습니다.

이전 컨테이너의 로그도 같이 봅니다. OOM이면 대개 끝이 뚝 잘려 있고 에러 메시지가 없습니다.

```bash
kubectl -n prod logs $POD --previous --tail=20
```

**2) 리소스와 사용량**

```bash
kubectl -n prod get deploy resizer \
  -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
# {"limits":{"memory":"64Mi"},"requests":{"memory":"32Mi"}}

kubectl top pod -n prod --containers
# POD            NAME      CPU   MEMORY
# resizer-xxxxx  resizer   5m    63Mi        ← limit 에 붙어 있다
```

`kubectl top` 은 metrics-server가 필요합니다. 없으면 `error: Metrics API not available` 이 나오고,
그때는 노드에서 `crictl stats` 또는 컨테이너 cgroup의 `memory.max` / `memory.current` 를 봅니다.
또 top은 스냅샷이라 죽기 직전의 피크를 놓칠 수 있습니다 — limit 근처 값이 보이면 그 자체로 충분한 근거입니다.

**3) 노드에 여유가 있는데 죽는 이유**: 메모리 limit은 노드 전체 가용량과 무관하게 컨테이너의
cgroup(`memory.max`)에 걸리는 하드 상한입니다. 컨테이너가 자기 limit을 넘어서 할당을 요구하면
커널 cgroup OOM killer가 그 컨테이너만 SIGKILL합니다. 노드 전체 메모리 압박(node-level OOM /
eviction)과는 완전히 별개의 메커니즘입니다.

**4) 수정**

```bash
kubectl -n prod set resources deploy resizer \
  --requests=memory=128Mi --limits=memory=256Mi
kubectl -n prod rollout status deploy resizer
```

사용량이 limit에 붙어 63Mi였으므로 실제 필요량은 64Mi 이상입니다. 여유를 두어 256Mi로 올리고
request는 128Mi로 둡니다. request를 limit과 같게 올리면 QoS가 `Guaranteed` 가 되지만 노드 여유가
적을 때 스케줄되지 않을 수 있으므로, 문제가 "스케줄 가능한 값" 을 요구한 만큼 낮게 둡니다.

**5) QoS**

```bash
kubectl -n prod get $POD -o jsonpath='{.status.qosClass}{"\n"}'   # Burstable

mkdir -p /opt/course/q14
cat > /opt/course/q14/qos.txt <<'EOF'
before: Burstable (requests 32Mi < limits 64Mi)
after:  Burstable (requests 128Mi < limits 256Mi)
EOF
```

QoS는 세 가지입니다. request = limit (모든 컨테이너, cpu·memory 모두)이면 `Guaranteed`,
하나라도 설정되어 있고 같지 않으면 `Burstable`, 아무것도 없으면 `BestEffort`.
노드 메모리 압박 시 축출 순서는 BestEffort → Burstable → Guaranteed 입니다. request와 limit을
같게 만들면 QoS가 `Guaranteed` 로 바뀝니다.

## 검증

```bash
kubectl -n prod get pods -l app=resizer
# READY 1/1, STATUS Running, RESTARTS 0 (새 파드) 이고 시간이 지나도 늘지 않음

kubectl -n prod get pod -l app=resizer \
  -o jsonpath='{.items[0].status.containerStatuses[0].lastState}{"\n"}'
# {}                     ← 이전 종료 기록이 없다

kubectl -n prod get deploy resizer \
  -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
# {"limits":{"memory":"256Mi"},"requests":{"memory":"128Mi"}}

kubectl top pod -n prod --containers      # limit 보다 충분히 낮은 사용량
kubectl -n prod get events --sort-by=.lastTimestamp | grep -i oom    # 새 항목 없음
cat /opt/course/q14/qos.txt
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: OOMKilled의 증거는 `lastState.terminated` 의 `reason: OOMKilled` + `exitCode: 137`.
- **헷갈리는 지점**: 같은 `CrashLoopBackOff` 겉모습에서 exit code 137(OOM, 외부 SIGKILL)과
  exit code 1(앱 자체 오류)은 완전히 다른 문제입니다. 137이면 로그를 뒤질 필요가 없고 limit을 봅니다.
  그리고 **CPU limit 초과는 컨테이너를 죽이지 않습니다** — 스로틀링만 됩니다. 메모리만 죽입니다.
  이 구분을 못 하면 CPU limit을 올리며 시간을 낭비합니다.

## 참고 문서

- 검색어: `troubleshoot exited containers OOM`
- https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/#exceed-a-container-s-memory-limit
- https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
