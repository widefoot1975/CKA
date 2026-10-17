#!/usr/bin/env bash
# c15 — Read output streams from a multi-container pod · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 필요: 5번의 네이티브 사이드카(initContainers + restartPolicy: Always)는 v1.29 이상
# 주의: namespace obs 는 mock_exam_f/q16 도 쓴다 — namespace 는 지우지 않고 이 문제의 파드만 지운다
set -euo pipefail

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
