#!/usr/bin/env bash
# b14 — Gateway accepts traffic but nothing reaches the backend · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: q08 과 같은 namespace gw 와 같은 리소스 이름을 쓴다. 실행하면 gw 를 지우고 새로 만든다.
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace gw (cleanup.sh 가 이 문제의 gw 인지 알아보도록 라벨을 붙인다)
kubectl delete ns gw --ignore-not-found --wait=true
rm -rf /opt/q14
kubectl create ns gw
kubectl label ns gw cka-lab=b14
mkdir -p /opt/q14

# 3) Gateway main-gw (listener http · HTTP · 80) — 이 설정은 정상이고 문제에서 바꾸지 않는다
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: main-gw, namespace: gw}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces: {from: Same}
YAML

# 4) 백엔드 shop-svc(80→80) / api-svc(8080→80)
#    어느 쪽으로 갔는지 보이도록 nginx 가 어떤 경로든 200 과 자기 이름을 돌려준다.
for app in shop-svc api-svc; do
kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: $app, namespace: gw, labels: {app: $app}}
spec:
  replicas: 1
  selector: {matchLabels: {app: $app}}
  template:
    metadata: {labels: {app: $app}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports: [{containerPort: 80}]
        command: ["/bin/sh", "-c"]
        args:
        - |
          echo 'server { listen 80; location / { default_type text/plain; return 200 "$app\n"; } }' > /etc/nginx/conf.d/default.conf
          exec nginx -g 'daemon off;'
YAML
done
kubectl -n gw expose deploy shop-svc --port=80 --target-port=80
kubectl -n gw expose deploy api-svc --port=8080 --target-port=80

# 5) 장애가 든 HTTPRoute 두 개 (내용은 풀이에서 확인)
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: store-route, namespace: gw}
spec:
  parentRefs:
  - name: main-gw
    sectionName: http
  hostnames:
  - shop.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - {name: shop-svc, port: 80}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: api-route, namespace: gw}
spec:
  parentRefs:
  - name: main-gw
    sectionName: http
  hostnames:
  - store.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /api}
    backendRefs:
    - {name: api-svc, port: 80}
YAML

kubectl -n gw rollout status deploy shop-svc --timeout=120s
kubectl -n gw rollout status deploy api-svc --timeout=120s
kubectl -n gw wait gateway main-gw --for=condition=Programmed --timeout=120s

# 6) 시작 상태 확인: Gateway PROGRAMMED True, 서비스 두 개, HTTPRoute 두 개
kubectl -n gw get gateway,svc,httproute
