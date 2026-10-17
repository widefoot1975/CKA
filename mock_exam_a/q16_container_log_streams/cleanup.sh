#!/usr/bin/env bash
# a16 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace logs 는 mock_exam_d/q16 도 쓴다. Deployment multi 만 지우고, 남은 리소스가 없을 때만 namespace 를 지운다.
set -euo pipefail

kubectl -n logs delete deploy multi --ignore-not-found --wait=true
kubectl -n logs wait --for=delete pod -l app=multi --timeout=90s 2>/dev/null || true

LEFT=$(kubectl -n logs get all,pvc,secret,configmap -o name 2>/dev/null \
         | grep -v -e '^configmap/kube-root-ca.crt$' || true)
if [ -z "$LEFT" ]; then
  kubectl delete ns logs --ignore-not-found
else
  echo "namespace logs 에 다른 리소스가 남아 있어 지우지 않음:"
  echo "$LEFT"
fi
