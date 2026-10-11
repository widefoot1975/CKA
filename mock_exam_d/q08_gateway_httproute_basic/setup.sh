#!/usr/bin/env bash
# d08 — Expose a Service through the Gateway API · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace + Deployment/Service frontend
kubectl delete ns web --ignore-not-found --wait=true
kubectl create ns web
kubectl -n web create deploy frontend --image=nginx:1.27
kubectl -n web expose deploy frontend --port=80
kubectl -n web rollout status deploy frontend

# 3) 시작 상태 확인: GatewayClass nginx ACCEPTED True, web 에는 Gateway/HTTPRoute 없음
kubectl get gatewayclass nginx
kubectl -n web get deploy,svc,gateway,httproute
