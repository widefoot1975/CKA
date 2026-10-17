#!/usr/bin/env bash
# b07 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns sched --ignore-not-found --wait=true
kubectl delete priorityclass critical-priority low-priority queue-jumper \
  team-batch ml-training ops-urgent zz-observer --ignore-not-found
rm -rf /opt/q07
