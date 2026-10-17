#!/usr/bin/env bash
# f16 — Collect logs from every container of a Pod · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace obs 는 mock_exam_c/q15 도 쓰므로 namespace 는 지우지 않고 이 문제의 파드만 정리한다.
set -euo pipefail

# 0) 이전 실습 흔적 정리 (이 문제가 만드는 파드만)
kubectl -n obs delete pod pipeline --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/f16

# 1) namespace + Pod pipeline: init 컨테이너 migrate → 컨테이너 ingest, transform
#    namespace 는 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns obs >/dev/null 2>&1; then
  kubectl create ns obs
  kubectl label ns obs cka-lab-f16=created --overwrite
fi
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
