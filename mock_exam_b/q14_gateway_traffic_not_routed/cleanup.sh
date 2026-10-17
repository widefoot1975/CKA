#!/usr/bin/env bash
# b14 — 실습 후 정리 (NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
# namespace gw 는 q08 도 쓴다. setup.sh 가 붙인 라벨 cka-lab=b14 가 있을 때만 지운다.
set -euo pipefail

if [ "$(kubectl get ns gw -o jsonpath='{.metadata.labels.cka-lab}' 2>/dev/null)" = "b14" ]; then
  kubectl delete ns gw --ignore-not-found
else
  echo "namespace gw 가 없거나 이 문제(b14)가 만든 것이 아니라서 남겨 둔다"
fi
rm -rf /opt/q14
