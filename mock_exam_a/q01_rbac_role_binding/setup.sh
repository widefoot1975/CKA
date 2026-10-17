#!/usr/bin/env bash
# a01 — Namespaced RBAC for a deployment operator · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (ServiceAccount·Role·RoleBinding 도 네임스페이스와 함께 지워진다)
kubectl delete ns staging --ignore-not-found --wait=true
kubectl create ns staging

# 1) 스케일 권한을 실제로 시험해 볼 Deployment
kubectl -n staging create deployment web --image=nginx:1.27 --replicas=1
kubectl -n staging rollout status deploy web --timeout=120s

# 2) 시작 상태 확인: Deployment web 만 있고 deploy-bot·Role·RoleBinding 은 없어야 한다
kubectl -n staging get sa,role,rolebinding,deploy
