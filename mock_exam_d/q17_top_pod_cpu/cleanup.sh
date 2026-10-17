#!/usr/bin/env bash
# d17 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace batch 은(는) mock_exam_c/q07 도 쓰므로 이 문제의 오브젝트만 지운다.
set -euo pipefail

kubectl -n batch delete pod cruncher-1 cruncher-2 idle-0 --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/d17
# metrics-server 는 다른 문제에서도 쓰므로 남겨 둔다

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-d17=created) 남은 리소스가 없을 때만 지운다
for ns in batch; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-d17}' 2>/dev/null || true)" = "created" ] || continue
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
