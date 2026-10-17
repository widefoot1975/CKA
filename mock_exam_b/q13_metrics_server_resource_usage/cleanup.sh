#!/usr/bin/env bash
# b13 — 실습 후 정리: metrics-server 를 동작하는 상태로 되돌린다 (다른 문제의 kubectl top·HPA 가 쓴다)
# 실행: bash cleanup.sh
set -euo pipefail

MS="kubectl -n kube-system"

# 1) metrics-server 에 --kubelet-insecure-tls 가 없으면 다시 넣고 Ready 가 될 때까지 기다린다
if $MS get deploy metrics-server >/dev/null 2>&1; then
  if ! $MS get deploy metrics-server \
       -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
    $MS patch deploy metrics-server --type=json \
      -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
  fi
  $MS scale deploy metrics-server --replicas=1
  $MS rollout status deploy metrics-server --timeout=180s
fi

# 2) 이 문제가 만든 것만 지운다 (prod 를 쓰는 다른 문제의 리소스는 남긴다)
kubectl -n prod delete deploy,hpa -l q13=b13 --ignore-not-found --wait=true 2>/dev/null || true
if [ "$(kubectl get ns prod -o jsonpath='{.metadata.labels.q13}' 2>/dev/null)" = "b13" ] \
   && [ -z "$(kubectl -n prod get all -o name 2>/dev/null)" ]; then
  kubectl delete ns prod
fi
rm -rf /opt/q13
