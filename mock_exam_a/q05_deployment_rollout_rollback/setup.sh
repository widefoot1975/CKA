#!/usr/bin/env bash
# a05 — Rolling update, pause and rollback · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — 이 문제는 namespace apps 부터 직접 만든다
kubectl delete ns apps --ignore-not-found --wait=true

# 1) 노드가 nginx 이미지를 받을 수 있는지 미리 확인 (오프라인 실습 환경 대비)
kubectl run img-check --image=nginx:1.27 --restart=Never --rm -i --pod-running-timeout=2m -- nginx -v || \
  echo "nginx 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"

# 2) 시작 상태 확인: namespace apps 가 없어야 함
kubectl get ns apps 2>/dev/null || echo "namespace apps 없음 (정상)"
