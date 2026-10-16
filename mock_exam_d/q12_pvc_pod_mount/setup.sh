#!/usr/bin/env bash
# d12 — PVC mounted in a Pod · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) local-path 프로비저너 v0.0.37 설치 (StorageClass local-path, WaitForFirstConsumer)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace data (PVC 를 지우면 local-path PV 도 Delete 정책으로 함께 지워진다)
kubectl delete ns data --ignore-not-found --wait=true
kubectl create ns data

# 3) 시작 상태 확인: local-path 가 WaitForFirstConsumer, data 에 PVC·파드 없음
kubectl get sc local-path
kubectl -n data get pvc,pod
