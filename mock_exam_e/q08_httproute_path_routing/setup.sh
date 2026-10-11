#!/usr/bin/env bash
# e08 — Route two paths with one HTTPRoute · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace 두 개
kubectl delete ns infra shop --ignore-not-found --wait=true
kubectl create ns infra
kubectl create ns shop

# 3) Gateway main-gw (listener http, 모든 네임스페이스의 route 허용) — kubectl create 로는 못 만들어서 이것만 YAML
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: main-gw, namespace: infra}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces: {from: All}
YAML

# 4) 백엔드: 어떤 경로든 자기 이름을 돌려주는 http-echo (컨테이너 포트 5678)
kubectl -n shop create deploy catalog --image=hashicorp/http-echo:1.0 -- /http-echo -text=catalog
kubectl -n shop create deploy cart    --image=hashicorp/http-echo:1.0 -- /http-echo -text=cart
kubectl -n shop expose deploy catalog --port=80   --target-port=5678
kubectl -n shop expose deploy cart    --port=8080 --target-port=5678
kubectl -n shop rollout status deploy catalog
kubectl -n shop rollout status deploy cart
kubectl -n infra wait gateway main-gw --for=condition=Programmed --timeout=120s

# 5) 시작 상태 확인: main-gw PROGRAMMED True, shop 에는 HTTPRoute 없음
kubectl -n infra get gateway main-gw
kubectl -n shop get deploy,svc,httproute
