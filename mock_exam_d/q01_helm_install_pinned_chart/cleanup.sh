#!/usr/bin/env bash
# d01 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

if helm status podinfo -n demo >/dev/null 2>&1; then
  helm uninstall podinfo -n demo --wait
fi
kubectl delete ns demo --ignore-not-found
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/d01
