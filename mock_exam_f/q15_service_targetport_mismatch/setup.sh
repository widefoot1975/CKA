#!/usr/bin/env bash
# f15 — Service targetPort mismatch · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns shop --ignore-not-found --wait=true
kubectl create ns shop

# 1) Deployment payments: nginx 2개 (label app=payments, nginx 는 80 에서 듣는다)
kubectl -n shop create deployment payments --image=nginx:1.27 --replicas=2 --port=80

# 2) Service payments: port 80 → targetPort 8080 (selector app=payments)
kubectl -n shop create service clusterip payments --tcp=80:8080

kubectl -n shop rollout status deploy payments --timeout=120s

# 3) 시작 상태 확인: 파드 2개 Ready, EndpointSlice 에 주소가 있음
kubectl -n shop get deploy,pod,svc
kubectl -n shop get endpointslice -l kubernetes.io/service-name=payments
