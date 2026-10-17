#!/usr/bin/env bash
# d08 — Expose a Service through the Gateway API · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace web 은 mock_exam_a/q06·q09, mock_exam_b/q05, mock_exam_f/q06 도 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다.
# 주의: mock_exam_b/q05 도 web 에 Deployment frontend 를 만들므로 함께 풀지 말 것
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 (이 문제가 만드는 오브젝트만)
kubectl -n web delete httproute frontend-route --ignore-not-found 2>/dev/null || true
kubectl -n web delete gateway web-gw --ignore-not-found 2>/dev/null || true
kubectl -n web delete svc frontend --ignore-not-found 2>/dev/null || true
kubectl -n web delete deploy frontend --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true

# 3) namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns web >/dev/null 2>&1; then
  kubectl create ns web
  kubectl label ns web cka-lab-d08=created --overwrite
fi
#    Deployment/Service frontend
kubectl -n web create deploy frontend --image=nginx:1.27
kubectl -n web expose deploy frontend --port=80
kubectl -n web rollout status deploy frontend

# 4) 시작 상태 확인: GatewayClass nginx ACCEPTED True, web 에는 Gateway/HTTPRoute 없음
kubectl get gatewayclass nginx
kubectl -n web get deploy,svc,gateway,httproute
