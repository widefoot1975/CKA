#!/usr/bin/env bash
# c11 — 실습 후 정리 (namespace data 는 C10·D12 도 쓰므로 이 문제의 리소스만 지운다.
#        local-path 프로비저너는 다른 Storage 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl -n data delete sts queue --ignore-not-found --wait=true
kubectl -n data delete svc queue --ignore-not-found
for pvc in $(kubectl -n data get pvc -o name 2>/dev/null | grep '^persistentvolumeclaim/data-queue-' || true); do
  kubectl -n data delete "$pvc" --wait=true
done
# setup.sh 가 만든 StorageClass 만 지운다 (원래 있던 standard 는 건드리지 않음)
kubectl delete sc -l cka-practice/created-by=c11 --ignore-not-found
