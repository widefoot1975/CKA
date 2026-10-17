#!/usr/bin/env bash
# a03 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

if helm status cert-manager -n cert-manager >/dev/null 2>&1; then
  helm uninstall cert-manager -n cert-manager --wait
fi
# crds.keep=true(기본) 라서 uninstall 뒤에도 CRD 가 남는다 — 직접 지운다
CRDS=$(kubectl get crd -o name | grep 'cert-manager\.io$' || true)
if [ -n "$CRDS" ]; then
  kubectl delete $CRDS
fi
kubectl delete ns cert-manager --ignore-not-found
helm repo remove jetstack >/dev/null 2>&1 || true
rm -rf /root/helm
