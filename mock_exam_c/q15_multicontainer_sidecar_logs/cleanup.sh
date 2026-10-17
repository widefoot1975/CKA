#!/usr/bin/env bash
# c15 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace obs 는 mock_exam_f/q16 도 쓰므로, 이 문제의 파드만 지우고 namespace 는 비었을 때만 지운다
set -euo pipefail

kubectl -n obs delete pod tracker tailer --ignore-not-found
if kubectl get ns obs >/dev/null 2>&1 && [ -z "$(kubectl -n obs get pods -o name 2>/dev/null)" ]; then
  kubectl delete ns obs --ignore-not-found
fi
rm -rf /opt/course/q15
