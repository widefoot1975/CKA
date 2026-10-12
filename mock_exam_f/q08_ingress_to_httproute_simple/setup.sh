#!/usr/bin/env bash
# f08 — Move an HTTP Ingress to an HTTPRoute · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace 두 개
kubectl delete ns gateway blog --ignore-not-found --wait=true
kubectl create ns gateway
kubectl create ns blog

# 3) Gateway public-gw (listener http, 모든 네임스페이스의 route 허용) — kubectl create 로는 못 만들어서 이것만 YAML
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: public-gw, namespace: gateway}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces: {from: All}
YAML

# 4) 백엔드: 어떤 경로든 정해진 문자열을 돌려주는 http-echo (컨테이너 포트 5678)
kubectl -n blog create deploy blog     --image=hashicorp/http-echo:1.0 -- /http-echo -text=blog-web
kubectl -n blog create deploy blog-api --image=hashicorp/http-echo:1.0 -- /http-echo -text=blog-api
kubectl -n blog expose deploy blog     --port=80   --target-port=5678
kubectl -n blog expose deploy blog-api --port=8080 --target-port=5678

# 5) 옮길 대상 Ingress blog (/ → blog:80, /api → blog-api:8080, 둘 다 Prefix)
kubectl -n blog create ingress blog --class=nginx \
  --rule='blog.example.com/*=blog:80' \
  --rule='blog.example.com/api*=blog-api:8080'

kubectl -n blog rollout status deploy blog
kubectl -n blog rollout status deploy blog-api
kubectl -n gateway wait gateway public-gw --for=condition=Programmed --timeout=120s

# 6) 시작 상태 확인: public-gw PROGRAMMED True, blog 에는 Ingress 만 있고 HTTPRoute 없음
kubectl -n gateway get gateway public-gw
kubectl -n blog get deploy,svc,ingress,httproute
