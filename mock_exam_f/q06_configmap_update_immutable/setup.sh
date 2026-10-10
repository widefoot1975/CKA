#!/usr/bin/env bash
# f06 — Update a ConfigMap and make it immutable · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: namespace web 을 새로 만든다 (mock_exam_b/q05 도 web 을 쓰므로 함께 풀지 말 것)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (immutable ConfigMap 은 수정할 수 없어서 namespace 째 지운다)
kubectl delete ns web --ignore-not-found --wait=true

# 1) namespace + ConfigMap app-config (LOG_LEVEL=debug)
kubectl create ns web
kubectl -n web create configmap app-config --from-literal=LOG_LEVEL=debug

# 2) Deployment api (nginx:1.27, envFrom 으로 app-config 전체 로드)
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        envFrom:
        - configMapRef:
            name: app-config
EOF

kubectl -n web rollout status deploy api

# 3) 설정 확인: 파드 환경 변수 LOG_LEVEL=debug
kubectl -n web get configmap app-config -o jsonpath='{.data}{" immutable="}{.immutable}{"\n"}'
kubectl -n web exec deploy/api -- printenv LOG_LEVEL
