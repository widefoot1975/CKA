#!/usr/bin/env bash
# b03 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

for c in $(kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="training.example.com")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete crd "$c"
done
kubectl delete ns cka --ignore-not-found
rm -rf /opt/q03
