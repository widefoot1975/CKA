#!/usr/bin/env bash
# e10 — Service targeting a named container port · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns api --ignore-not-found --wait=true
kubectl create ns api

# 1) Deployment backend: nginx:1.27, 컨테이너 이름 nginx, ports 선언 없음
kubectl -n api create deploy backend --image=nginx:1.27
kubectl -n api rollout status deploy backend --timeout=120s

# 2) 시작 상태 확인: 컨테이너 ports 가 비어 있고 Service 가 없어야 함
kubectl -n api get deploy backend -o jsonpath='{.spec.template.spec.containers[0].name} ports={.spec.template.spec.containers[0].ports}{"\n"}'
kubectl -n api get svc
