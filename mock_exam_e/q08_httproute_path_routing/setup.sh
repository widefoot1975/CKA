#!/usr/bin/env bash
# e08 — Route two paths with one HTTPRoute · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace infra 는 mock_exam_c/q05 가, shop 은 A08·A15·C06·C08·D05·F15 가 함께 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다.
# 주의: mock_exam_c/q08 도 shop 에 HTTPRoute shop-route 를 만들므로 함께 풀지 말 것
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 (이 문제가 만드는 오브젝트만)
kubectl -n shop delete httproute shop-route --ignore-not-found 2>/dev/null || true
kubectl -n shop delete svc catalog cart --ignore-not-found 2>/dev/null || true
kubectl -n shop delete deploy catalog cart --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n infra delete gateway main-gw --ignore-not-found 2>/dev/null || true
#    namespace 두 개 — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns infra >/dev/null 2>&1; then
  kubectl create ns infra
  kubectl label ns infra cka-lab-e08=created --overwrite
fi
if ! kubectl get ns shop >/dev/null 2>&1; then
  kubectl create ns shop
  kubectl label ns shop cka-lab-e08=created --overwrite
fi

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
