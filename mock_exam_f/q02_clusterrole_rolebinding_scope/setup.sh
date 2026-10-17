#!/usr/bin/env bash
# f02 — ClusterRole bound in one namespace · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (ClusterRole·ClusterRoleBinding 은 클러스터 범위라 따로 지운다)
kubectl delete clusterrolebinding anna-deploy-view --ignore-not-found
kubectl delete clusterrole deployment-viewer --ignore-not-found
kubectl delete ns team-a team-b --ignore-not-found --wait=true

# 1) 네임스페이스 두 개와, 읽어 볼 Deployment 하나씩
kubectl create ns team-a
kubectl create ns team-b
kubectl -n team-a create deployment web-a --image=nginx:1.27
kubectl -n team-b create deployment web-b --image=nginx:1.27

# 2) 시작 상태 확인: dev-anna 는 아직 아무 권한이 없다 (모두 no)
kubectl auth can-i list deployments -n team-a --as=dev-anna || true
kubectl auth can-i list deployments -n team-b --as=dev-anna || true
