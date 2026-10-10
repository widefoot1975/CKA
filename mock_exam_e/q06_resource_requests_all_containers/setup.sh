#!/usr/bin/env bash
# e06 — Set resources on every container, including init · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns wp --ignore-not-found --wait=true

# 1) namespace
kubectl create ns wp

# 2) Deployment wordpress (init 컨테이너 init-perms + 앱 컨테이너 wordpress, resources 없음)
#    init 컨테이너는 imperative 로 못 만들어서 YAML 로 작성
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: wp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      initContainers:
      - name: init-perms
        image: busybox:1.36
        command: ["sh", "-c", "chown -R 33:33 /var/www/html"]
        volumeMounts:
        - name: html
          mountPath: /var/www/html
      containers:
      - name: wordpress
        image: wordpress:6-apache
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html
          mountPath: /var/www/html
      volumes:
      - name: html
        emptyDir: {}
YAML

# 3) 시작 상태 확인: 파드 2개 Running, resources 비어 있음
kubectl -n wp rollout status deploy wordpress
kubectl -n wp get deploy wordpress \
  -o jsonpath='{.spec.template.spec.initContainers[0].resources}{"\n"}{.spec.template.spec.containers[0].resources}{"\n"}'
