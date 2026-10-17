#!/usr/bin/env bash
# c10 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace data 는 c11 · d12 와 같이 쓰므로, 이 문제의 리소스만 지우고 비었을 때만 namespace 를 지운다
set -euo pipefail

kubectl -n data delete sts db --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n data delete svc db db-rw --ignore-not-found 2>/dev/null || true
kubectl -n data delete pod t v v2 --ignore-not-found 2>/dev/null || true
rm -rf /opt/course/q10

if kubectl get ns data >/dev/null 2>&1; then
  LEFT=$(kubectl -n data get all,pvc,cm,secret -o name 2>/dev/null \
         | grep -v -e '^configmap/kube-root-ca.crt$' -e '^service/kubernetes$' || true)
  if [ -z "$LEFT" ]; then
    kubectl delete ns data --ignore-not-found
  else
    echo "namespace data 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$LEFT"
  fi
fi
