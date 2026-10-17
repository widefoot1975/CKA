#!/usr/bin/env bash
# b10 — 실습 후 정리 (이 문제가 만든 리소스만 지우고, 비어 있는 namespace 만 지운다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl -n alpha delete deploy/alpha-web svc/alpha-web --ignore-not-found 2>/dev/null || true
kubectl -n beta  delete pod/probe --ignore-not-found 2>/dev/null || true
for ns in alpha beta; do
  kubectl get ns "$ns" >/dev/null 2>&1 || continue
  if [ -z "$(kubectl -n "$ns" get deploy,sts,ds,svc,pod,job,cronjob -o name 2>/dev/null)" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 문제의 리소스가 남아 있어 namespace 는 지우지 않음"
  fi
done
rm -rf /opt/q10
