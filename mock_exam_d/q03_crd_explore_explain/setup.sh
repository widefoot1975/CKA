#!/usr/bin/env bash
# d03 — Explore installed CRDs with kubectl · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 결과 파일 정리
rm -rf /opt/course/d03

# 1) cert-manager 설치 (이미 있으면 그대로 유지)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl wait --for=condition=Established crd/certificates.cert-manager.io --timeout=120s
kubectl -n cert-manager wait --for=condition=Available deploy --all --timeout=180s

# 2) 결과 파일 디렉터리
mkdir -p /opt/course/d03

# 3) 설정 확인
kubectl get crd | grep cert-manager.io
