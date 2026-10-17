#!/usr/bin/env bash
# c08 — Weighted traffic splitting with HTTPRoute · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace 두 개
kubectl delete ns gateway-system shop --ignore-not-found --wait=true
kubectl create ns gateway-system
kubectl create ns shop

# 3) Gateway web-gw (listener http, 모든 네임스페이스의 route 허용) — kubectl create 로는 못 만들어서 YAML
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: web-gw, namespace: gateway-system}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces: {from: All}
YAML

# 4) Deployment shop-v1 / shop-v2 (nginx:1.27, 컨테이너 포트 80)
#    어떤 경로든 200 과 자기 이름(shop-v1 / shop-v2)을 돌려주도록 nginx 설정만 바꾼다. Service 는 문제에서 만든다.
for v in v1 v2; do
kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: shop-$v, namespace: shop, labels: {app: shop-$v}}
spec:
  replicas: 1
  selector: {matchLabels: {app: shop-$v}}
  template:
    metadata: {labels: {app: shop-$v, version: $v}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports: [{containerPort: 80}]
        command: ["/bin/sh", "-c"]
        args:
        - |
          echo 'server { listen 80; location / { default_type text/plain; return 200 "shop-$v\n"; } }' > /etc/nginx/conf.d/default.conf
          exec nginx -g 'daemon off;'
YAML
done
kubectl -n shop rollout status deploy shop-v1
kubectl -n shop rollout status deploy shop-v2
kubectl -n gateway-system wait gateway web-gw --for=condition=Programmed --timeout=120s

# 5) 시작 상태 확인: web-gw PROGRAMMED True, shop 에는 Deployment 두 개만 있고 Service·HTTPRoute 없음
kubectl -n gateway-system get gateway web-gw
kubectl -n shop get deploy,svc,httproute
