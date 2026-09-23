# q14 — A container is being OOMKilled · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `prod` 의 Deployment `resizer` 가 계속 재시작한다. `kubectl get pods` 에서
`RESTARTS` 가 올라가고 파드가 `Running` 과 `CrashLoopBackOff` 를 오간다. 이미지는 정상이고,
스테이징에서 측정한 최대 메모리 사용량은 약 180Mi였다.

1. 컨테이너가 스스로 크래시한 것이 아니라 메모리 때문에 죽는 것임을 확인한다. 어떤 필드를 읽고
   어떤 종료 코드를 기대하는지 적는다.
2. 컨테이너의 현재 메모리 request와 limit, 실제 사용량을 보고하고, 노드에 여유 메모리가 있는데도
   죽은 이유를 한 줄로 설명한다.
3. Deployment에서 컨테이너의 메모리 request를 `128Mi`, limit을 `256Mi` 로 바꾸고 재시작이
   멈추는지 확인한다.
4. 변경 전과 후의 파드 QoS 클래스를 `/opt/course/q14/qos.txt` 에 쓰고, 이 컨테이너가 `Guaranteed`
   가 되려면 무엇이 더 필요한지 적는다.
5. `prod` 의 단독 Pod `cache-warm`(컨테이너 `cache`)은 메모리 limit `64Mi` 로 정상 동작 중이지만
   오늘 밤 부하 테스트 전에 여유가 필요하다. 파드를 **삭제·재생성·재시작하지 않고** 메모리 request를
   `128Mi`, limit을 `256Mi` 로 올리고, 새 값이 적용되었으며 재시작 횟수가 그대로임을 보인다.

## 모범 풀이

**1) OOM 확정** — 지금 상태(`state`)가 아니라 직전 종료 기록(`lastState`)을 봐야 합니다.

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
137은 외부 SIGKILL이면 다 나오므로, OOM이라는 확정은 `reason: OOMKilled` 로 합니다. 파드가 지금
Running이면 `state.running` 만 보고 "정상"이라고 오판하기 쉽습니다.

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

kubectl -n prod get $POD -o jsonpath='{.status.qosClass}{"\n"}'   # Burstable — 3번에서 파드가 교체되기 전에 적어 둔다
```

`kubectl top` 은 metrics-server가 필요합니다. 없으면 `error: Metrics API not available` 이 나오고,
그때는 노드에서 `crictl stats` 또는 컨테이너 cgroup의 `memory.max` / `memory.current` 를 봅니다.
top은 스냅샷이라 죽기 직전의 피크를 놓칠 수 있습니다 — limit 근처 값이 보이면 그 자체로 충분한 근거입니다.

**노드에 여유가 있는데 죽는 이유**: 메모리 limit은 노드 전체 가용량과 무관하게 컨테이너의
cgroup(`memory.max`)에 걸리는 하드 상한입니다. 컨테이너가 자기 limit을 넘어서 할당을 요구하면
커널 cgroup OOM killer가 그 컨테이너만 SIGKILL합니다. 노드 전체 메모리 압박(node-level OOM /
eviction)과는 별개의 메커니즘입니다.

**3) Deployment 수정**

```bash
kubectl -n prod set resources deploy resizer \
  --requests=memory=128Mi --limits=memory=256Mi
kubectl -n prod rollout status deploy resizer
```

측정된 피크(약 180Mi)가 새 limit(256Mi) 안에 여유 있게 들어갑니다. Deployment의 파드 템플릿을
바꾸는 것이므로 **새 파드로 롤아웃**됩니다 — 기존 파드를 그 자리에서 고치는 것이 아닙니다(그건 5번).

**4) QoS**

```bash
# 변경 전 값은 2번에서 적어 둔 것(Burstable). 3번의 롤아웃으로 옛 파드는 이미 사라졌다
NEW=$(kubectl -n prod get pod -l app=resizer -o name | head -1)
kubectl -n prod get $NEW -o jsonpath='{.status.qosClass}{"\n"}'   # 변경 후 파드: Burstable

mkdir -p /opt/course/q14
cat > /opt/course/q14/qos.txt <<'EOF'
before: Burstable (memory request 32Mi < limit 64Mi)
after:  Burstable (memory request 128Mi < limit 256Mi)
Guaranteed needs: every container with cpu AND memory requests == limits (e.g. cpu 250m/250m, memory 256Mi/256Mi)
EOF
```

`Guaranteed` 가 되려면 **모든 컨테이너**가 **cpu와 memory 둘 다** request = limit이어야 합니다.
이 컨테이너는 cpu를 아예 설정하지 않았으므로, memory만 request = limit으로 맞춰도 여전히
`Burstable` 입니다. 아무것도 설정하지 않으면 `BestEffort` 입니다.

**5) 파드를 다시 만들지 않고 올리기 — in-place resize (1.35 GA)**

1.35부터 실행 중인 파드의 CPU·메모리 request/limit을 **`resize` 서브리소스**로 바꿀 수 있습니다.
일반 `kubectl edit pod` / `patch pod` 로 `resources` 를 바꾸면 여전히 거부되므로, 반드시
`--subresource resize` 를 붙입니다(kubectl 1.32 이상).

```bash
kubectl -n prod get pod cache-warm \
  -o jsonpath='{.status.containerStatuses[0].restartCount}{"\n"}'          # 예: 0

kubectl -n prod patch pod cache-warm --subresource resize --patch \
  '{"spec":{"containers":[{"name":"cache","resources":{"requests":{"memory":"128Mi"},"limits":{"memory":"256Mi"}}}]}}'

kubectl -n prod get pod cache-warm -o jsonpath=\
'{.spec.containers[0].resources}{"\n"}{.status.containerStatuses[0].resources}{"\n"}{.status.containerStatuses[0].restartCount}{"\n"}'
# {"limits":{"memory":"256Mi"},"requests":{"memory":"128Mi"}}   ← 원하는 값(spec)
# {"limits":{"memory":"256Mi"},"requests":{"memory":"128Mi"}}   ← 실제 적용된 값(status)
# 0                                                            ← 재시작 없음
```

- `status.containerStatuses[].resources` 가 spec과 같아지면 적용이 끝난 것입니다. 노드에 여유가 없으면
  `PodResizePending`(reason `Deferred`/`Infeasible`), 적용 중이면 `PodResizeInProgress` 컨디션이 붙습니다.
- 컨테이너를 재시작할지는 `resizePolicy` 가 정합니다. 기본값 `NotRequired` 면 재시작 없이 cgroup
  값만 바뀝니다. `RestartContainer` 로 지정된 리소스는 컨테이너를 재시작해서 적용합니다.
- resize로 **QoS 클래스는 바꿀 수 없습니다.** Burstable → Guaranteed처럼 클래스가 달라지는 변경은
  거부되므로, 그런 변경은 파드를 다시 만들어야 합니다.
- Deployment가 관리하는 파드에 resize를 해도 템플릿은 그대로입니다. 파드가 다시 만들어지면 원래 값으로
  돌아가므로, 오래 유지할 값은 3번처럼 템플릿에 반영합니다.

## 검증

```bash
kubectl -n prod get pods -l app=resizer
# READY 1/1, STATUS Running, RESTARTS 0 (새 파드) 이고 시간이 지나도 늘지 않음

kubectl -n prod get deploy resizer \
  -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
# {"limits":{"memory":"256Mi"},"requests":{"memory":"128Mi"}}

kubectl -n prod get events --sort-by=.lastTimestamp | grep -i oom    # 새 항목 없음
cat /opt/course/q14/qos.txt

kubectl -n prod get pod cache-warm \
  -o jsonpath='{.status.containerStatuses[0].resources.limits.memory} {.status.containerStatuses[0].restartCount}{"\n"}'
# 256Mi 0
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: OOMKilled의 증거는 `lastState.terminated` 의 `reason: OOMKilled` + `exitCode: 137`. 실행 중인 파드의 리소스는 `kubectl patch pod --subresource resize` 로 재시작 없이 바꿀 수 있다(1.35 GA). 단, QoS 클래스는 바꿀 수 없다.
- **헷갈리는 지점**: 같은 `CrashLoopBackOff` 겉모습에서 exit code 137(OOM, 외부 SIGKILL)과
  exit code 1(앱 자체 오류)은 완전히 다른 문제입니다. 137이면 로그를 뒤질 필요가 없고 limit을 봅니다.
  그리고 **CPU limit 초과는 컨테이너를 죽이지 않습니다** — 스로틀링만 됩니다. 메모리만 죽입니다.
  `Guaranteed` 는 memory만 맞춰서는 안 되고 모든 컨테이너의 cpu·memory가 모두 request = limit이어야 합니다.

## 참고 문서

- 검색어: `troubleshoot exited containers OOM`, `resize container resources`
- https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/#exceed-a-container-s-memory-limit
- https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/
- https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
