#!/usr/bin/env bash
# e12 — Share a memory-backed emptyDir · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (tmp 네임스페이스는 이 문제만 쓴다)
kubectl delete ns tmp --ignore-not-found --wait=true

# 1) 문제에서 "이미 있다"고 한 네임스페이스 tmp
kubectl create ns tmp

# 2) 시작 상태 확인: tmp 는 Active, cache-pod 는 없음
kubectl get ns tmp
kubectl -n tmp get pods
