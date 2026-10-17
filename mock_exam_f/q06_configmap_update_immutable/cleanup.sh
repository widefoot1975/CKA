#!/usr/bin/env bash
# f06 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace web 은(는) mock_exam_a/q06·q09, mock_exam_b/q05, mock_exam_d/q08 도 쓰므로 이 문제의 오브젝트만 지운다.
set -euo pipefail

kubectl -n web delete deploy api --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n web delete configmap app-config --ignore-not-found 2>/dev/null || true

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-f06=created) 남은 리소스가 없을 때만 지운다
for ns in web; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-f06}' 2>/dev/null || true)" = "created" ] || continue
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
