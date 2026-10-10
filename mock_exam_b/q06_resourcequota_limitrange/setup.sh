#!/usr/bin/env bash
# b06 — ResourceQuota and LimitRange · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (namespace team-a 는 문제에서 직접 만든다)
kubectl delete ns team-a --ignore-not-found --wait=true
rm -rf /opt/q06

# 1) 답안 파일 디렉터리
mkdir -p /opt/q06

# 2) 설정 확인: team-a 가 없어야 함
kubectl get ns team-a 2>/dev/null || echo "namespace team-a 없음 (정상)"
ls -ld /opt/q06
