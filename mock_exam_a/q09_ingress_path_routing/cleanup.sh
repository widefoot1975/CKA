#!/usr/bin/env bash
# a09 — 실습 후 정리 (NGINX Ingress Controller 는 다른 Ingress 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
# namespace web 은 다른 문제(b05, d08, f06)도 쓰므로 이 문제의 리소스만 지우고,
# 지운 뒤 web 에 아무것도 남지 않았을 때만 namespace 를 지운다.
set -euo pipefail

kubectl -n web delete ingress shop-ingress --ignore-not-found
kubectl -n web delete svc site-svc api-svc --ignore-not-found
kubectl -n web delete deploy site api --ignore-not-found --cascade=foreground --wait=true
kubectl -n web delete pod img-check --ignore-not-found --wait=true

if kubectl get ns web >/dev/null 2>&1; then
  left=$(kubectl -n web get deploy,sts,ds,job,cronjob,pod,svc,ingress,cm,secret,pvc -o name 2>/dev/null \
    | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns web --ignore-not-found
  else
    echo "namespace web 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
fi
