#!/usr/bin/env bash
# e07 — Add a native sidecar to an existing Deployment · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns synergy --ignore-not-found --wait=true

# 1) namespace + Deployment synergy-app (컨테이너 app 하나, emptyDir logs 를 /var/log 에 마운트)
kubectl create ns synergy
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synergy-app
  namespace: synergy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synergy-app
  template:
    metadata:
      labels:
        app: synergy-app
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo \"$(date) processed\" >> /var/log/app.log; sleep 5; done"]
        volumeMounts:
        - name: logs
          mountPath: /var/log
      volumes:
      - name: logs
        emptyDir: {}
EOF

kubectl -n synergy rollout status deploy synergy-app

# 2) 설정 확인: 파드 1/1, initContainers 없음
kubectl -n synergy get pods
kubectl -n synergy get deploy synergy-app \
  -o jsonpath='{.spec.template.spec.containers[*].name}{" | init: "}{.spec.template.spec.initContainers}{"\n"}'
