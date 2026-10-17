#!/usr/bin/env bash
# f09 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns app --ignore-not-found
rm -rf /opt/course/f09
