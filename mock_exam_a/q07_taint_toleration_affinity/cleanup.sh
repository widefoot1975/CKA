#!/usr/bin/env bash
# a07 — 실습 후 정리 (taint 를 남기면 다른 문제의 파드가 worker02 에 못 올라감)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl -n default delete pod batch-runner web-front --ignore-not-found
kubectl taint node worker02 workload=batch:NoSchedule- 2>/dev/null || true
kubectl label nodes -l 'tier in (batch,web)' tier- 2>/dev/null || true
