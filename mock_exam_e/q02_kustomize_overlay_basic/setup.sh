#!/usr/bin/env bash
# e02 — Apply a Kustomize overlay · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns staging --ignore-not-found --wait=true
rm -rf /opt/course/e02

# 1) base 및 overlays 디렉터리 구조 생성
mkdir -p /opt/course/e02/base
mkdir -p /opt/course/e02/overlays/staging

# 2) Deployment api (nginx:1.27, 1 replica)
cat <<'EOF' > /opt/course/e02/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 1
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
        ports:
        - containerPort: 80
EOF

# 3) Service api
cat <<'EOF' > /opt/course/e02/base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 80
EOF

# 4) base kustomization.yaml
cat <<'EOF' > /opt/course/e02/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
EOF

# 5) 설정 확인
find /opt/course/e02 | sort
kubectl kustomize /opt/course/e02/base > /dev/null && echo "base renders OK"
