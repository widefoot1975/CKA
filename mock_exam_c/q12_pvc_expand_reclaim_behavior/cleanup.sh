#!/usr/bin/env bash
# c12 — 실습 후 정리 (slow-retain PV 를 Delete 로 되돌린 뒤 지운다. local-path 프로비저너는 다른 Storage 문제에서도 쓰므로 남겨 둔다)
# StorageClass slow 는 반드시 지운다 — A12 는 slow 라는 StorageClass 가 없다는 전제로 풀린다
# 실행: bash cleanup.sh
set -euo pipefail

for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="slow-retain")]}{.metadata.name}{"\n"}{end}'); do
  kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
done
kubectl delete ns files --ignore-not-found --wait=true
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="slow-retain")]}{.metadata.name}{"\n"}{end}{range .items[?(@.spec.claimRef.namespace=="files")]}{.metadata.name}{"\n"}{end}'); do
  # Released 는 프로비저너가 디렉터리째 지우도록 잠시 기다리고, Available(5번에서 claimRef 를 지운 것)은 바로 지운다
  if [ "$(kubectl get pv "$pv" -o jsonpath='{.status.phase}' 2>/dev/null)" = "Released" ]; then
    kubectl wait --for=delete "pv/$pv" --timeout=60s || true
  fi
  kubectl delete pv "$pv" --ignore-not-found --wait=true
done
kubectl delete sc slow slow-retain --ignore-not-found
