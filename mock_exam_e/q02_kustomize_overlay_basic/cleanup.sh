#!/usr/bin/env bash
# e02 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns staging --ignore-not-found
rm -rf /opt/course/e02
