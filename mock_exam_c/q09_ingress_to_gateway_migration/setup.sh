#!/usr/bin/env bash
# c09 — Migrate a TLS Ingress to the Gateway API · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace secure + 답안 디렉터리
kubectl delete ns secure --ignore-not-found --wait=true
rm -rf /opt/course/q09
mkdir -p /opt/course/q09
kubectl create ns secure

# 3) 백엔드: Deployment portal (nginx:1.27, 3 레플리카) + Service portal:80
kubectl -n secure create deploy portal --image=nginx:1.27 --replicas=3 --port=80
kubectl -n secure expose deploy portal --port=80

# 4) TLS Secret portal-tls (자체 서명, CN·SAN = portal.example.com)
TMP=$(mktemp -d)
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout "$TMP/tls.key" -out "$TMP/tls.crt" \
  -subj "/CN=portal.example.com" -addext "subjectAltName=DNS:portal.example.com"
kubectl -n secure create secret tls portal-tls --cert="$TMP/tls.crt" --key="$TMP/tls.key"
rm -rf "$TMP"

# 5) 옮길 대상 Ingress portal-ing (IngressClass nginx, portal.example.com TLS 종료, / → portal:80)
kubectl -n secure create ingress portal-ing --class=nginx \
  --rule='portal.example.com/*=portal:80,tls=portal-tls'

kubectl -n secure rollout status deploy portal

# 6) 시작 상태 확인: GatewayClass nginx ACCEPTED True, secure 에는 Ingress 만 있고 Gateway·HTTPRoute 없음
kubectl get gatewayclass nginx
kubectl -n secure get deploy,svc,secret,ingress,gateway,httproute
