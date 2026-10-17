#!/usr/bin/env bash
# q02 — Deploy an environment overlay with Kustomize · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns prod-web --ignore-not-found --wait=true
rm -rf /opt/course/q02

# 1) base 및 overlays 디렉터리 구조 생성
mkdir -p /opt/course/q02/base
mkdir -p /opt/course/q02/overlays/prod

# 2) Deployment web (nginx:1.25, 1 replica, containerPort 80)
cat <<'EOF' > /opt/course/q02/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

# 3) Service web
cat <<'EOF' > /opt/course/q02/base/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
EOF

# 4) base kustomization.yaml
cat <<'EOF' > /opt/course/q02/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
EOF

# 5) 설정 확인
find /opt/course/q02 | sort
kubectl kustomize /opt/course/q02/base > /dev/null && echo "base renders OK"
