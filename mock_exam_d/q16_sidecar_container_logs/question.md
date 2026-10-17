# q16 — Read logs from an app and its sidecar

| Item | Value |
|---|---|
| Exam | mock_exam_d |
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
kubectl delete ns logs --ignore-not-found --wait=true
rm -rf /opt/course/d16

# 1) namespace + Pod order-api
#    - log-agent: 네이티브 사이드카, 시작하자마자 15줄을 찍고 5초마다 INFO/ERROR 를 남긴다
#    - api: 첫 실행은 FATAL 을 남기고 exit 1 → 한 번 재시작한 뒤에는 계속 돈다 (emptyDir 의 표식 파일로 구분)
kubectl create ns logs
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: order-api
  namespace: logs
spec:
  initContainers:
  - name: log-agent
    image: busybox:1.36
    restartPolicy: Always
    command:
    - sh
    - -c
    - |
      for i in $(seq 1 15); do echo "$(date -u +%FT%TZ) INFO agent ready, buffered line $i"; done
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 4)) -eq 0 ]; then echo "$(date -u +%FT%TZ) ERROR upstream rejected batch $i"
        else echo "$(date -u +%FT%TZ) INFO shipped batch $i"; fi
        sleep 5
      done
  containers:
  - name: api
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      if [ ! -f /state/started ]; then
        touch /state/started
        echo "$(date -u +%FT%TZ) INFO api starting (first run)"
        echo "$(date -u +%FT%TZ) FATAL cannot reach database, exiting"
        sleep 3
        exit 1
      fi
      echo "$(date -u +%FT%TZ) INFO api restarted, serving orders"
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 3)) -eq 0 ]; then echo "$(date -u +%FT%TZ) ERROR payment timeout order=$i"
        else echo "$(date -u +%FT%TZ) INFO order $i processed"; fi
        sleep 5
      done
    volumeMounts:
    - name: state
      mountPath: /state
  volumes:
  - name: state
    emptyDir: {}
EOF

# 2) api 가 한 번 재시작하고 파드가 Ready 가 될 때까지 기다린다
for i in $(seq 1 60); do
  RC=$(kubectl -n logs get pod order-api -o jsonpath='{.status.containerStatuses[?(@.name=="api")].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done
kubectl -n logs wait pod order-api --for=condition=Ready --timeout=120s

# 3) 답안 파일 디렉터리
mkdir -p /opt/course/d16

# 4) 설정 확인: READY 2/2, RESTARTS 1
kubectl -n logs get pod order-api
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `order-api` 는 `READY 2/2`, `RESTARTS 1` 이다. `api` 의 첫 인스턴스는 FATAL 을 남기고 exit 1 로 죽었고, 두 컨테이너 모두 5초마다 INFO/ERROR 줄을 남긴다.
네이티브 사이드카를 쓰므로 v1.29 이상 클러스터가 필요하다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns logs --ignore-not-found
rm -rf /opt/course/d16
```

</details>

## Task

Namespace `logs` contains pod `order-api` with an app container `api` and a native sidecar
container `log-agent` (declared under `initContainers` with `restartPolicy: Always`).

1. Write the last 10 lines of the `log-agent` container's log to `/opt/course/d16/agent.log`.
2. Container `api` has restarted once. Write the log of its previous instance to
   `/opt/course/d16/api-previous.log`.
3. Write every log line from the last 30 minutes, from all containers of the pod, that contains
   `ERROR` to `/opt/course/d16/errors.log`. Each line must be prefixed with the name of the
   container it came from.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
