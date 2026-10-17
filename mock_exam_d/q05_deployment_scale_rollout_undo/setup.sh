#!/usr/bin/env bash
# d05 — Deployment scale, image update and rollback · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (리비전 기록까지 지우려면 네임스페이스째 새로 만든다)
kubectl delete ns shop --ignore-not-found --wait=true
kubectl create ns shop

# 1) Deployment web: nginx:1.27, 2 replicas (컨테이너 이름은 이미지에서 딴 nginx)
kubectl -n shop create deploy web --image=nginx:1.27 --replicas=2
kubectl -n shop rollout status deploy web --timeout=120s

# 2) 시작 상태 확인: 2/2 Ready, 이미지 nginx:1.27, 리비전 1개
kubectl -n shop get deploy web -o wide
kubectl -n shop rollout history deploy web
