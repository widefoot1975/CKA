#!/usr/bin/env bash
# e08 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace shop, infra 은(는) mock_exam_c/q05(infra)와 A08·A15·C06·C08·D05·F15(shop) 도 쓰므로 이 문제의 오브젝트만 지운다.
set -euo pipefail

kubectl -n shop delete httproute shop-route --ignore-not-found 2>/dev/null || true
kubectl -n shop delete svc catalog cart --ignore-not-found 2>/dev/null || true
kubectl -n shop delete deploy catalog cart --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n infra delete gateway main-gw --ignore-not-found 2>/dev/null || true
# NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 남겨 둔다

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-e08=created) 남은 리소스가 없을 때만 지운다
for ns in shop infra; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-e08}' 2>/dev/null || true)" = "created" ] || continue
  left=$( { kubectl -n "$ns" get all,configmap,secret,ingress,pvc,networkpolicy -o name 2>/dev/null
            kubectl -n "$ns" get gateway,httproute -o name 2>/dev/null; } \
          | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
done
