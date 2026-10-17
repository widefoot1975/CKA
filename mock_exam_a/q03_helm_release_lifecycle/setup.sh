#!/usr/bin/env bash
# a03 — Manage a cluster component with Helm · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: 클러스터에 있는 cert-manager 를 모두 지운다 (d03 setup 이 설치한 것 포함)
set -euo pipefail

# 0) helm 이 설치되어 있는지 확인 (없으면 여기서 멈춘다)
helm version --short

# 1) 기존 cert-manager 제거: Helm 릴리스 → kubectl 매니페스트 설치분 → 남은 CRD 순서
if helm status cert-manager -n cert-manager >/dev/null 2>&1; then
  helm uninstall cert-manager -n cert-manager --wait
fi
if kubectl -n cert-manager get deploy cert-manager >/dev/null 2>&1; then
  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml --ignore-not-found
fi
CRDS=$(kubectl get crd -o name | grep 'cert-manager\.io$' || true)
if [ -n "$CRDS" ]; then
  kubectl delete $CRDS --wait=true      # crds.keep=true 로 남은 CRD 까지 지운다
fi
kubectl delete ns cert-manager --ignore-not-found --wait=true

# 2) 저장소와 결과 파일 정리
helm repo remove jetstack >/dev/null 2>&1 || true
rm -rf /root/helm
mkdir -p /root/helm

# 3) 시작 상태 확인: cert-manager 의 흔적이 없어야 한다
kubectl get crd | grep cert-manager.io || echo "cert-manager CRD 없음 (정상)"
helm list -A | grep cert-manager || echo "cert-manager 릴리스 없음 (정상)"
