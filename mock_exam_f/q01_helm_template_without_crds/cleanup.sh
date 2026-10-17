#!/usr/bin/env bash
# f01 — 실습 후 정리 (릴리스, 네임스페이스, 저장소 등록, Helm 밖에서 설치한 CRD 까지 지운다)
# 실행: bash cleanup.sh
set -euo pipefail

helm uninstall argocd -n argocd 2>/dev/null || true
kubectl delete ns argocd --ignore-not-found --wait=true
helm repo remove argo 2>/dev/null || true
kubectl get crd -o name | grep 'argoproj.io' | xargs -r kubectl delete
rm -rf /opt/course/f01
