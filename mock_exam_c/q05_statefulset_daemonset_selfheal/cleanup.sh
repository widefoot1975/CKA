#!/usr/bin/env bash
# c05 — 실습 후 정리
# 실행: bash cleanup.sh
# 이 문제의 객체만 지운다. namespace infra 는 setup.sh 가 만들었고 남은 리소스가 없을 때만 지운다.
set -euo pipefail

kubectl -n infra delete ds node-agent --ignore-not-found 2>/dev/null || true
kubectl -n infra delete sts cache --ignore-not-found 2>/dev/null || true
kubectl -n infra delete pod -l app=cache --ignore-not-found 2>/dev/null || true
kubectl -n infra delete svc cache --ignore-not-found 2>/dev/null || true

if [ "$(kubectl get ns infra -o jsonpath='{.metadata.labels.cka-lab-c05}' 2>/dev/null || true)" = "created" ]; then
  kubectl -n infra wait pod --all --for=delete --timeout=120s 2>/dev/null || true
  if [ -z "$(kubectl -n infra get all --no-headers 2>/dev/null)" ]; then
    kubectl delete ns infra --ignore-not-found
  else
    echo "namespace infra 에 다른 리소스가 남아 있어 namespace 는 지우지 않았습니다."
  fi
fi
