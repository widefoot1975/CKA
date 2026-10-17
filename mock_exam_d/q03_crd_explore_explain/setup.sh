#!/usr/bin/env bash
# d03 — Explore installed CRDs with kubectl · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 결과 파일 정리
rm -rf /opt/course/d03

# 1) cert-manager 설치 (a03 처럼 Helm 으로 이미 설치돼 있으면 건드리지 않는다)
if kubectl get crd certificates.cert-manager.io >/dev/null 2>&1; then
  echo "cert-manager 가 이미 설치돼 있음 — 설치 건너뜀"
else
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
fi
kubectl wait --for=condition=Established crd/certificates.cert-manager.io --timeout=120s
kubectl -n cert-manager wait --for=condition=Available deploy --all --timeout=180s

# 2) 결과 파일 디렉터리
mkdir -p /opt/course/d03

# 3) 설정 확인
kubectl get crd | grep cert-manager.io
