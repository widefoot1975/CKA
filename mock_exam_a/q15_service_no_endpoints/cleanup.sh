#!/usr/bin/env bash
# a15 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

# 이 문제의 오브젝트만 지운다 (namespace shop 은 다른 문제도 쓴다)
kubectl -n shop delete deploy api --ignore-not-found --cascade=foreground --wait=true
kubectl -n shop delete svc api-svc --ignore-not-found --wait=true
kubectl -n shop delete pod tmp --ignore-not-found

# shop 에 다른 문제의 리소스가 남아 있지 않으면 namespace 도 지운다
left=$(kubectl api-resources --verbs=list --namespaced -o name 2>/dev/null \
  | grep -vE '^(events|events\.events\.k8s\.io|endpoints|endpointslices\.discovery\.k8s\.io)$|metrics\.k8s\.io$' | paste -sd, - \
  | xargs -r kubectl -n shop get --ignore-not-found -o name 2>/dev/null \
  | grep -vE '^(configmap/kube-root-ca\.crt|serviceaccount/default)$' || true)
if [ -z "$left" ]; then
  kubectl delete ns shop --ignore-not-found
else
  echo "namespace shop 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
  echo "$left"
fi
