#!/usr/bin/env bash
# f11 — 실습 후 정리 (Retain 으로 바꾼 PV 를 Delete 로 되돌린 뒤 지운다. local-path 프로비저너는 다른 Storage 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
set -euo pipefail

for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="db")]}{.metadata.name}{"\n"}{end}'); do
  kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
done
kubectl delete ns db --ignore-not-found --wait=true
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="db")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete pv "$pv" --ignore-not-found
done
rm -rf /opt/course/f11
