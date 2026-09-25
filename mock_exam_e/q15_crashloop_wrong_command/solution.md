# q15 — Fix a crash-looping Deployment · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`jobs` 네임스페이스의 Deployment `worker`(레플리카 1, 이미지 `busybox:1.36`)가 `CrashLoopBackOff`
상태다. 컨테이너 `worker` 는 시작 메시지를 출력한 뒤 `sleep 3600` 을 실행해야 한다.

1. 컨테이너 `worker` 의 **이전**(죽은) 인스턴스의 로그를 `/opt/course/e15/previous.log` 에 쓴다.
2. 그 컨테이너가 마지막으로 종료될 때의 exit code를 `/opt/course/e15/exitcode.txt` 에 쓴다.
3. 컨테이너가 계속 실행되도록 Deployment를 고친다. 이미지는 바꾸지 않는다.
4. 새 파드가 `Running` 이고 재시작 횟수가 더 늘지 않는지 확인한다.

## 모범 풀이

**증거를 먼저 모으고 나서 고칩니다.** Deployment를 고치면 새 파드가 생기고 옛 파드는 지워지므로, 옛
파드의 이전 로그도 함께 사라집니다.

```bash
mkdir -p /opt/course/e15
kubectl -n jobs get pods
# NAME                      READY   STATUS             RESTARTS      AGE
# worker-6b8d9c7f4d-q7x2m   0/1     CrashLoopBackOff   5 (40s ago)   4m
POD=$(kubectl -n jobs get pods -o jsonpath='{.items[0].metadata.name}')
```

**1) 이전 인스턴스의 로그** — `--previous`(`-p`)는 마지막으로 종료된 인스턴스를 가리킵니다.

```bash
kubectl -n jobs logs $POD -c worker --previous > /opt/course/e15/previous.log
cat /opt/course/e15/previous.log
# worker starting
# sh: sleeep: not found
```

**2) 마지막 종료 코드** — `state` 는 지금, `lastState.terminated` 는 직전에 죽은 인스턴스입니다.

```bash
kubectl -n jobs get pod $POD \
  -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}{"\n"}' \
  | tee /opt/course/e15/exitcode.txt
# 127
```

`kubectl describe pod` 의 `Last State: Terminated / Reason: Error / Exit Code: 127` 로도 보입니다.
**127은 셸의 "command not found"** 이고, 로그의 `sleeep: not found` 와 정확히 맞습니다.

| Exit code | 흔한 의미 |
|---|---|
| 0 | 명령이 정상 종료 — 계속 떠 있어야 할 컨테이너라면 포그라운드 프로세스가 없는 것 |
| 1 | 애플리케이션 오류 |
| 126 | 파일은 있지만 실행할 수 없음(권한) |
| 127 | 명령을 찾을 수 없음 (오타, 이미지에 없는 실행 파일) |
| 137 | SIGKILL(128+9) — 보통 OOMKilled |
| 143 | SIGTERM(128+15) — 외부 종료 요청 |

**3) 수정**

```bash
kubectl -n jobs get deploy worker -o jsonpath='{.spec.template.spec.containers[0].command}{"\n"}'
# ["sh","-c","echo worker starting; sleeep 3600"]
kubectl -n jobs edit deploy worker          # sleeep → sleep, 저장하면 새 파드로 롤아웃된다
```

## 검증

```bash
kubectl -n jobs rollout status deploy worker
kubectl -n jobs get pods
# NAME                      READY   STATUS    RESTARTS   AGE
# worker-5f7c6d9b8-z4k1n    1/1     Running   0          40s      ← 새 파드, RESTARTS 가 0 에서 멈춰 있다
kubectl -n jobs logs deploy/worker          # worker starting
cat /opt/course/e15/exitcode.txt            # 127
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CrashLoop의 원인은 `kubectl logs --previous` 와 `lastState.terminated.exitCode` 에 있다. 127 = command not found.
- **헷갈리는 지점**: `CrashLoopBackOff` 는 원인이 아니라 "죽어서 재시작을 미루는 중"이라는 상태 이름입니다. 셸 없이 `command: ["sleeep", "3600"]` 처럼 실행 파일 자체가 없으면 127이 아니라 컨테이너가 시작 단계에서 실패해 `StartError`(containerd 기준 exit code 128)와 `executable file not found in $PATH` 가 찍히고, `--previous` 로그는 비어 있습니다.

## 참고 문서

- 검색어: `debug running pods`, `determine the reason for pod failure`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/
- https://kubernetes.io/docs/tasks/debug/debug-application/determine-reason-pod-failure/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
