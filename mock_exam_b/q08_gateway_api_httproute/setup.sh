#!/usr/bin/env bash
# b08 — Expose a service with the Gateway API · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
#    NGF 가 CRD 없이는 뜨지 않아 CRD 도 함께 깐다. 문제 1번은 "설치돼 있는지 확인"하는 단계가 된다.
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 (namespace gw 와 백엔드는 문제에서 직접 만든다)
kubectl delete ns gw --ignore-not-found --wait=true
rm -rf /opt/q08

# 3) 답안 파일 디렉터리
mkdir -p /opt/q08

# 4) 시작 상태 확인: GatewayClass nginx ACCEPTED True, namespace gw 없음
kubectl get gatewayclass nginx
kubectl get ns gw 2>/dev/null || echo "namespace gw 없음 (정상)"
ls -ld /opt/q08
