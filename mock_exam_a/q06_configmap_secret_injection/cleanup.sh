#!/usr/bin/env bash
# a06 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace web 은 다른 문제도 쓰므로, 이 문제의 오브젝트만 지우고 web 이 비었을 때만 namespace 를 지운다
set -euo pipefail

if kubectl get ns web >/dev/null 2>&1; then
  kubectl -n web delete pod web-app --ignore-not-found --wait=true
  kubectl -n web delete configmap app-config app-files --ignore-not-found
  kubectl -n web delete secret db-cred --ignore-not-found

  left=$(kubectl -n web get all,ingress,pvc,configmap,secret -o name 2>/dev/null \
           | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns web
  else
    echo "namespace web 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
fi
