#!/usr/bin/env bash
# f06 — Update a ConfigMap and make it immutable · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace web 은 mock_exam_a/q06·q09, mock_exam_b/q05, mock_exam_d/q08 도 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다.
# 주의: mock_exam_a/q06 도 ConfigMap app-config 를, mock_exam_a/q09 도 Deployment api 를 web 에 만들므로 함께 풀지 말 것
set -euo pipefail

# 0) 이전 실습 흔적 정리 (immutable ConfigMap 은 수정할 수 없어서 지우고 다시 만든다)
kubectl -n web delete deploy api --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n web delete configmap app-config --ignore-not-found 2>/dev/null || true

# 1) namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns web >/dev/null 2>&1; then
  kubectl create ns web
  kubectl label ns web cka-lab-f06=created --overwrite
fi
#    ConfigMap app-config (LOG_LEVEL=debug)
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
