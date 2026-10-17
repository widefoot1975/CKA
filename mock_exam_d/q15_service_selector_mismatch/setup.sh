#!/usr/bin/env bash
# d15 — A Service with no endpoints · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns store --ignore-not-found --wait=true

# 1) namespace + Deployment catalog (파드 라벨 app=catalog)
kubectl create ns store
kubectl -n store create deploy catalog --image=nginx:1.27 --replicas=2 --port=80
kubectl -n store rollout status deploy catalog

# 2) Service catalog — selector 철자가 틀렸다 (catalogue)
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: catalog
  namespace: store
spec:
  selector:
    app: catalogue
  ports:
  - port: 80
    targetPort: 80
EOF

# 3) 설정 확인: 파드 2개 Ready, EndpointSlice 의 ENDPOINTS 는 비어 있음
kubectl -n store get pods --show-labels
kubectl -n store get endpointslice -l kubernetes.io/service-name=catalog
