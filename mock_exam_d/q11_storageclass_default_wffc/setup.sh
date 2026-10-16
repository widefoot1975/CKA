#!/usr/bin/env bash
# d11 — Default StorageClass with WaitForFirstConsumer · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) local-path 프로비저너 v0.0.37 설치 (StorageClass local-path 가 함께 생긴다)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리: local-fast 를 지우고 local-path 를 다시 기본 클래스로
kubectl delete sc local-fast --ignore-not-found
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class=true --overwrite

# 3) 시작 상태 확인: local-path (default) 하나, local-fast 없음
kubectl get sc
