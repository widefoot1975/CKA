#!/usr/bin/env bash
# e15 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns jobs --ignore-not-found
rm -rf /opt/course/e15
