#!/usr/bin/env bash
# f07 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns ops --ignore-not-found
rm -rf /opt/course/f07
