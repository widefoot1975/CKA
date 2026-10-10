#!/usr/bin/env bash
# q05 — 실습 후 정리 (default-workload 가 globalDefault 이므로 꼭 실행)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns priority --ignore-not-found
kubectl delete priorityclass high-priority batch-low default-workload \
  team-standard team-critical zz-preempt-never --ignore-not-found
