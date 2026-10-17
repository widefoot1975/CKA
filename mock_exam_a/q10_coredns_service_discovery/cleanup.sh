#!/usr/bin/env bash
# a10 — 실습 후 정리 (이 문제가 만든 리소스만 지우고, 비어 있는 namespace 만 지운다)
# 실행: bash cleanup.sh
set -euo pipefail

for ns in alpha beta; do
  kubectl get ns "$ns" >/dev/null 2>&1 || continue
  kubectl -n "$ns" delete deploy/web svc/web pod/no-dns pod/dns --ignore-not-found
  if [ -z "$(kubectl -n "$ns" get deploy,sts,ds,svc,pod,job,cronjob -o name 2>/dev/null)" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 문제의 리소스가 남아 있어 namespace 는 지우지 않음"
  fi
done
