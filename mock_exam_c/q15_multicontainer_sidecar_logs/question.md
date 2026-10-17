# q15 — Read output streams from a multi-container pod

| Item | Value |
|---|---|
| Exam | mock_exam_c |
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
# 0) 이전 실습 흔적 정리 (이 문제의 파드만)
kubectl -n obs delete pod tracker tailer --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/q15

# 1) namespace (없을 때만 만든다) + Pod tracker
#    - setup: init 컨테이너, 몇 줄 찍고 끝난다 (ERROR 한 줄 포함)
#    - app: 시작하자마자 30줄을 찍고 5초마다 INFO/ERROR 를 남긴다
#    - shipper: 첫 실행은 ERROR 를 남기고 exit 1 → 한 번 재시작한 뒤에는 계속 돈다 (emptyDir 의 표식 파일로 구분)
kubectl create ns obs --dry-run=client -o yaml | kubectl apply -f -
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: tracker
  namespace: obs
spec:
  initContainers:
  - name: setup
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      echo "$(date -u +%FT%TZ) INFO setup: writing config"
      echo "$(date -u +%FT%TZ) ERROR setup: optional cache dir missing, continuing"
      echo "$(date -u +%FT%TZ) INFO setup: done"
  containers:
  - name: app
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      for i in $(seq 1 30); do echo "$(date -u +%FT%TZ) INFO app warmup step $i"; done
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 4)) -eq 0 ]; then echo "$(date -u +%FT%TZ) ERROR app request $i failed: upstream 503"
        else echo "$(date -u +%FT%TZ) INFO app request $i ok"; fi
        sleep 5
      done
  - name: shipper
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      if [ ! -f /state/started ]; then
        touch /state/started
        echo "$(date -u +%FT%TZ) INFO shipper starting (first run)"
        echo "$(date -u +%FT%TZ) ERROR shipper cannot connect to log backend, exiting"
        sleep 3
        exit 1
      fi
      echo "$(date -u +%FT%TZ) INFO shipper restarted, connected to log backend"
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 5)) -eq 0 ]; then echo "$(date -u +%FT%TZ) ERROR shipper batch $i dropped"
        else echo "$(date -u +%FT%TZ) INFO shipper batch $i shipped"; fi
        sleep 5
      done
    volumeMounts:
    - name: state
      mountPath: /state
  volumes:
  - name: state
    emptyDir: {}
EOF

# 2) shipper 가 한 번 재시작하고 파드가 Ready 가 될 때까지 기다린다
for i in $(seq 1 60); do
  RC=$(kubectl -n obs get pod tracker -o jsonpath='{.status.containerStatuses[?(@.name=="shipper")].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done
kubectl -n obs wait pod tracker --for=condition=Ready --timeout=120s

# 3) 답안 파일 디렉터리
mkdir -p /opt/course/q15

# 4) 설정 확인: READY 2/2, RESTARTS 1
kubectl -n obs get pod tracker
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `tracker` 는 `READY 2/2`, `RESTARTS 1` 이다. `setup` 은 세 줄을 찍고 끝났고, `app` 과 `shipper` 는 INFO 사이사이 ERROR 를 남긴다.
5번의 네이티브 사이드카를 쓰므로 v1.29 이상 클러스터가 필요하다. namespace `obs` 는 mock_exam_f/q16 과 같이 쓰므로 정리할 때 이 문제의 파드만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n obs delete pod tracker tailer --ignore-not-found
# obs 에 다른 파드가 없을 때만 namespace 를 지운다
[ -z "$(kubectl -n obs get pods -o name 2>/dev/null)" ] && kubectl delete ns obs --ignore-not-found
rm -rf /opt/course/q15
```

</details>

## Task

Namespace `obs` contains pod `tracker` with containers `app`, `shipper` and an init
container `setup`. A colleague ran `kubectl logs tracker`, got output without any error,
and concluded that `shipper` is healthy.

1. Report which container the plain `kubectl logs tracker` actually printed and why, and
   list the pod's containers (including the init container) without reading the whole
   manifest. Then make `shipper` the container a plain `kubectl logs tracker` shows,
   without recreating the pod.
2. Write the last 20 lines of the `app` container's log to
   `/opt/course/q15/app.log`.
3. The `shipper` container restarted once. Write the log of its **previous** instance to
   `/opt/course/q15/shipper-prev.log` and state the restart reason.
4. Write every line produced by any container in the last 10 minutes containing the
   string `ERROR` to `/opt/course/q15/errors.log`.
5. Create a new pod `tailer` in `obs` that runs `nginx:1.27` writing access logs to
   `/var/log/nginx/access.log` on a shared `emptyDir`, plus a native sidecar named
   `logship` (`busybox:1.36`) that tails that file to its own stdout. Prove that
   `kubectl logs tailer -c logship` shows nginx requests.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
