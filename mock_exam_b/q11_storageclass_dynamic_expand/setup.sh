#!/usr/bin/env bash
# b11 — StorageClass dynamic provisioning and expansion · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) local-path 프로비저너 v0.0.37 설치 (StorageClass local-path 가 함께 생긴다)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리 (namespace store 는 D15 도 쓰므로 지우지 않고 이 문제의 리소스만 지운다)
kubectl -n store delete pod writer --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n store delete pvc data-pvc --ignore-not-found --wait=true 2>/dev/null || true
kubectl delete sc fast-expand --ignore-not-found
rm -rf /opt/q11

# 3) 시작 상태: local-path 가 기본 클래스이고 확장을 허용하지 않는다
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class=true --overwrite
kubectl patch sc local-path -p '{"allowVolumeExpansion":false}'
kubectl create ns store --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /opt/q11

# 4) 시작 상태 확인: local-path (default), ALLOWVOLUMEEXPANSION false, fast-expand 없음
kubectl get sc
kubectl -n store get pvc,pod
