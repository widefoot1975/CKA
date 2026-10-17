#!/usr/bin/env bash
# f09 — Least permissive NetworkPolicy · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (namespace 를 지우면 적용했던 후보 정책도 함께 지워진다)
kubectl delete ns app --ignore-not-found --wait=true
rm -rf /opt/course/f09
kubectl create ns app

# 1) 파드 두 개: backend 는 8080 에서 HTTP 응답, frontend 는 busybox
kubectl -n app run backend  --image=hashicorp/http-echo:1.0 --labels=app=backend --port=8080 -- -listen=:8080 -text=backend
kubectl -n app run frontend --image=busybox:1.36 --labels=app=frontend -- sleep 3600

# 2) 이미 있는 정책 default-deny-ingress (모든 파드의 ingress 차단) — kubectl create 로는 못 만들어서 YAML
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny-ingress, namespace: app}
spec:
  podSelector: {}
  policyTypes: [Ingress]
YAML

# 3) 후보 정책 세 개 (적용하지 않고 파일로만 둔다)
mkdir -p /opt/course/f09
cat > /opt/course/f09/policy-a.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-a
  namespace: app
spec:
  podSelector:
    matchLabels: {app: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector: {}
YAML
cat > /opt/course/f09/policy-b.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-b
  namespace: app
spec:
  podSelector:
    matchLabels: {app: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels: {app: frontend}
    ports:
    - {protocol: TCP, port: 8080}
YAML
cat > /opt/course/f09/policy-c.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-c
  namespace: app
spec:
  podSelector:
    matchLabels: {app: backend}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - {protocol: TCP, port: 8080}
YAML

kubectl -n app wait pod --all --for=condition=Ready --timeout=120s

# 4) 시작 상태 확인: frontend → backend 가 막혀 있어야 함 (닿으면 CNI 가 NetworkPolicy 를 지원하지 않는 것)
kubectl -n app get pods --show-labels
kubectl -n app get netpol
ls /opt/course/f09
BIP=$(kubectl -n app get pod backend -o jsonpath='{.status.podIP}')
kubectl -n app exec frontend -- wget -qO- -T 3 http://$BIP:8080 || echo "frontend → backend 막힘 (정상)"
