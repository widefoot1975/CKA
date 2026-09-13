# q14 — Diagnose a CrashLoopBackOff pod · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`dev` 네임스페이스의 Pod `broken-app` 이 `CrashLoopBackOff` 상태다.

1. 재시작 횟수와, 실패하는 컨테이너의 마지막 종료 코드·종료 이유를 보고한다.
2. 지금 기동 중인 인스턴스가 아니라 **죽은** 인스턴스의 출력을 읽는다.
3. 아무것도 바꾸기 전에 종료 코드로부터 가장 가능성 높은 원인을 짚는다.
4. 파드가 `Running` 을 유지하도록 수리한다.
5. 종료 코드 0, 1, 127, 137의 통상적인 원인을 각각 한 줄로 적는다.
6. 로그를 읽지 않고 `CrashLoopBackOff` 와 `ImagePullBackOff` 를 구분하는 방법을 한 줄로 적는다.

## 모범 풀이

**1) 상태를 숫자로 확정합니다**

```bash
kubectl -n dev get pod broken-app
# broken-app   0/1   CrashLoopBackOff   6 (2m ago)   11m
kubectl -n dev describe pod broken-app
# Last State: Terminated / Reason: Error|OOMKilled|Completed / Exit Code: 137
# Events: Back-off restarting failed container
kubectl -n dev get pod broken-app \
  -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}{" "}{.status.containerStatuses[0].lastState.terminated.reason}{"\n"}'
```

`state` 는 지금, `lastState` 는 직전에 죽은 인스턴스입니다. `CrashLoopBackOff` 는 그 자체로 원인이 아니라 "컨테이너가 죽어서 재시작을 지수적으로 미루는 중"이라는 상태 이름일 뿐입니다. 원인은 항상 `lastState.terminated` 에 있습니다.

**2) 죽은 인스턴스의 로그**

```bash
kubectl -n dev logs broken-app --previous
kubectl -n dev logs broken-app --previous --tail=50
kubectl -n dev logs broken-app -c '<컨테이너>' --previous   # 컨테이너가 여러 개면 필수
kubectl -n dev get events --sort-by=.lastTimestamp | tail -15
```

**`--previous` 없이 `kubectl logs` 를 치면 아무것도 못 봅니다.** 현재 인스턴스는 방금 시작했거나 아직 컨테이너가 없어서 로그가 비었거나 `container ... is waiting to start` 에러가 납니다. 실패한 파드의 로그는 거의 항상 `--previous` 입니다.

**3) 종료 코드로 원인 좁히기**

| Exit code | describe의 Reason | 의미 | 확인·조치 |
|---|---|---|---|
| 0 | `Completed` (그런데 RESTARTS 증가) | 포그라운드 프로세스가 없어 명령이 즉시 끝남 | 계속 사는 명령으로 바꾸거나 Job/CronJob으로 만든다 |
| 1 / 2 | `Error` | 애플리케이션 자체 오류 — 설정 누락, 잘못된 인자, 필수 env 없음 | `logs --previous` 의 에러 문장 |
| 127 | `Error` | command not found — 이미지에 그 실행 파일이 없음 | `command`/`args` 철자, 이미지에 셸이 있는지 |
| 137 | `OOMKilled` | SIGKILL(128+9). 대개 메모리 limit 초과 | `resources.limits.memory` 상향 또는 앱 사용량 축소 |
| 143 | `Error` | SIGTERM(128+15) — 외부에서 종료 요청 | probe 실패로 kubelet이 죽였는지 확인 |

`OOMKilled` 인지 확인하는 가장 확실한 방법은 exit code가 아니라 `Reason` 필드입니다. 137은 외부 SIGKILL일 수도 있지만 cgroup OOM killer가 죽인 경우에만 `Reason: OOMKilled` 가 찍힙니다.

liveness probe가 원인일 수도 있습니다. 이때는 Events에 `Liveness probe failed:` 가 반복되고 컨테이너는 정상인데 계속 죽습니다.

```bash
kubectl -n dev describe pod broken-app | grep -i -A3 'liveness\|readiness'
```

**4) 수리**

Pod의 대부분 필드는 불변입니다. 이미지만 바꿀 때는 in-place가 되지만 `command`, `env`, 볼륨은 안 되므로 다시 만들어야 합니다.

```bash
kubectl -n dev set image pod/broken-app '<컨테이너>=<올바른이미지>'   # 이미지만 문제면

kubectl -n dev get pod broken-app -o yaml > /tmp/broken-app.yaml   # 그 외에는 다시 만든다
# status, metadata의 uid/resourceVersion/creationTimestamp 제거 후 수정
kubectl -n dev replace --force -f /tmp/broken-app.yaml              # delete + apply 를 한 번에
```

Deployment가 관리하는 파드라면 파드를 지우지 말고 Deployment를 고칩니다. 파드만 지우면 같은 문제의 파드가 즉시 다시 생깁니다.

**6) 두 상태의 구분** — `kubectl -n dev get pods` 의 STATUS와 RESTARTS만 봐도 됩니다.

`ImagePullBackOff` / `ErrImagePull` 은 **컨테이너가 한 번도 시작하지 못한** 상태라 `RESTARTS` 가 0이고 `lastState` 가 비어 있습니다. Events에 `Failed to pull image` / `manifest unknown` 이 찍힙니다. `CrashLoopBackOff` 는 컨테이너가 실행된 뒤 종료된 것이라 `RESTARTS` 가 올라가고 종료 코드가 남습니다. 즉 **RESTARTS 숫자와 `lastState` 존재 여부**로 로그 없이 구분됩니다.

## 검증

```bash
kubectl -n dev get pod broken-app -w
# broken-app   1/1   Running   0   ...      ← RESTARTS가 더 늘지 않아야 한다
kubectl -n dev logs broken-app --tail=20             # 정상 기동 로그
kubectl -n dev get pod broken-app -o jsonpath='{.status.containerStatuses[0].state}{"\n"}'
# {"running":{"startedAt":"..."}}
kubectl -n dev describe pod broken-app | grep -A3 'Last State'   # 새 종료 기록 없음
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 죽은 컨테이너의 로그는 `kubectl logs <pod> --previous`. 현재 로그를 봐도 아무것도 없다.
- **헷갈리는 지점**: `state` 와 `lastState` 를 섞어 보는 것. 원인은 `lastState.terminated` 에 있습니다. 그리고 exit code 0에 RESTARTS가 증가하는 경우를 "정상 종료"로 오독하기 쉽습니다 — 이건 포그라운드 프로세스가 없어서 명령이 바로 끝난 것이고, `restartPolicy: Always` 가 계속 다시 띄우는 중입니다.

## 참고 문서

- 검색어: `debug running pods`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
