#!/usr/bin/env bash
# a15 — A Service with no endpoints · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — namespace shop 은 A08·C08·D05·E08·F15 도 쓰므로 namespace 는 지우지 않고
#    이 문제의 오브젝트만 지운다 (A08 도 Deployment api 를 만들므로 A08 의 api 는 여기서 바뀐다)
kubectl create ns shop --dry-run=client -o yaml | kubectl apply -f -
kubectl -n shop delete deploy api --ignore-not-found --cascade=foreground --wait=true
kubectl -n shop delete svc api-svc --ignore-not-found --wait=true

# 1) Deployment api: 파드 3개, 라벨 app=api, 컨테이너는 8080 에서 듣는다 (nginx-unprivileged 기본 포트)
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: shop
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: nginxinc/nginx-unprivileged:1.27
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          periodSeconds: 5
YAML

# 2) Service api-svc — 고장 두 개: selector 가 app=api-server, targetPort 가 80
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: api-svc
  namespace: shop
spec:
  selector:
    app: api-server
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
YAML

kubectl -n shop rollout status deploy api --timeout=120s

# 3) 시작 상태 확인: 파드 3개 Ready, EndpointSlice 의 ENDPOINTS 는 비어 있음
kubectl -n shop get pods -l app=api
kubectl -n shop get endpointslice -l kubernetes.io/service-name=api-svc
