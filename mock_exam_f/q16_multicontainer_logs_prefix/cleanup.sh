#!/usr/bin/env bash
# f16 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns obs --ignore-not-found
rm -rf /opt/course/f16
