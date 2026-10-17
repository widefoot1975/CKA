#!/usr/bin/env bash
# e17 — 실습 후 정리 (metrics-server 는 다른 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl -n monitoring delete pod -l cka=e17 --ignore-not-found
# namespace 는 setup.sh 가 직접 만들었을 때(cka=e17 표시)만 지운다
if [ "$(kubectl get ns monitoring -o jsonpath='{.metadata.labels.cka}' 2>/dev/null || true)" = "e17" ]; then
  kubectl delete ns monitoring --ignore-not-found
fi
rm -rf /opt/course/e17
