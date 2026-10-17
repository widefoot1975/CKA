#!/usr/bin/env bash
# b11 — 실습 후 정리
# local-path 프로비저너는 다른 Storage 문제에서도 쓰고, namespace store 는 D15 도 쓰므로 남겨 둔다
# 실행: bash cleanup.sh
set -euo pipefail

kubectl -n store delete pod writer --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n store delete pvc data-pvc --ignore-not-found --wait=true 2>/dev/null || true
kubectl delete sc fast-expand --ignore-not-found
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class=true --overwrite
rm -rf /opt/q11
