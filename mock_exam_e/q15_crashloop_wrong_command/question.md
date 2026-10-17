# q15 — Fix a crash-looping Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns jobs --ignore-not-found --wait=true
rm -rf /opt/course/e15

# 1) namespace + Deployment worker — command 에 오타(sleeep)가 있어 시작 메시지만 찍고 바로 죽는다
kubectl create ns jobs
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
  namespace: jobs
spec:
  replicas: 1
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      containers:
      - name: worker
        image: busybox:1.36
        command: ["sh", "-c", "echo worker starting; sleeep 3600"]
EOF

# 2) 한 번 이상 재시작할 때까지 기다린다 (그래야 --previous 로그가 생긴다)
for i in $(seq 1 60); do
  RC=$(kubectl -n jobs get pod -l app=worker -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 3) 답안 파일 디렉터리
mkdir -p /opt/course/e15

# 4) 설정 확인: STATUS 가 Error / CrashLoopBackOff, RESTARTS 1 이상
kubectl -n jobs get pods
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `jobs` 의 파드 `worker-...` 는 `Error` 또는 `CrashLoopBackOff` 이고 RESTARTS 가 1 이상이다. 그래서 `--previous` 로그가 이미 있다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns jobs --ignore-not-found
rm -rf /opt/course/e15
```

</details>

## Task

Deployment `worker` in namespace `jobs` (1 replica, image `busybox:1.36`) is in
`CrashLoopBackOff`. Its container `worker` is supposed to print a start message and then run
`sleep 3600`.

1. Write the logs of the **previous** (crashed) instance of container `worker` to
   `/opt/course/e15/previous.log`.
2. Write the exit code of that container's last termination to `/opt/course/e15/exitcode.txt`.
3. Fix the Deployment so that the container keeps running. Do not change the image.
4. Confirm that the new pod is `Running` and that its restart count does not increase any more.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
