#!/usr/bin/env bash
# f16 — Collect logs from every container of a Pod · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns obs --ignore-not-found --wait=true
rm -rf /opt/course/f16

# 1) namespace + Pod pipeline: init 컨테이너 migrate → 컨테이너 ingest, transform
kubectl create ns obs
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pipeline
  namespace: obs
spec:
  initContainers:
  - name: migrate
    image: busybox:1.36
    command: ["sh", "-c", "echo 'migrate: applying 001_init'; echo 'migrate: applying 002_orders'; echo 'migrate: done'"]
  containers:
  - name: ingest
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      i=0
      while true; do i=$((i+1)); echo "INFO ingest received record $i"; sleep 4; done
  - name: transform
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 3)) -eq 0 ]; then echo "ERROR transform failed on record $i: bad schema"
        else echo "INFO transform ok record $i"; fi
        sleep 4
      done
EOF
kubectl -n obs wait pod pipeline --for=condition=Ready --timeout=120s

# 2) 답안 파일 디렉터리
mkdir -p /opt/course/f16

# 3) 설정 확인: READY 2/2 (init 컨테이너는 끝났으므로 세지 않음)
kubectl -n obs get pod pipeline
