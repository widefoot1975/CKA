#!/usr/bin/env bash
# d10 — NetworkPolicy allow from one frontend · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns proj --ignore-not-found --wait=true
kubectl create ns proj

# 1) 파드 세 개: backend 는 8080 에서 HTTP 응답, frontend·other 는 busybox
kubectl -n proj run backend  --image=hashicorp/http-echo:1.0 --labels=app=backend --port=8080 -- -listen=:8080 -text=backend
kubectl -n proj run frontend --image=busybox:1.36 --labels=app=frontend -- sleep 3600
kubectl -n proj run other    --image=busybox:1.36 --labels=app=other    -- sleep 3600

# 2) 이미 있는 정책 deny-all (모든 파드의 ingress 차단) — kubectl create 로는 못 만들어서 이것만 YAML
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-all, namespace: proj}
spec:
  podSelector: {}
  policyTypes: [Ingress]
YAML

kubectl -n proj wait pod --all --for=condition=Ready --timeout=120s

# 3) 시작 상태 확인: frontend 에서도 backend 로 안 닿아야 함 (닿으면 CNI 가 NetworkPolicy 를 지원하지 않는 것)
kubectl -n proj get pods --show-labels
kubectl -n proj get netpol
BIP=$(kubectl -n proj get pod backend -o jsonpath='{.status.podIP}')
kubectl -n proj exec frontend -- wget -qO- -T 3 http://$BIP:8080 || echo "frontend → backend 막힘 (정상)"
