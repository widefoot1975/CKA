#!/usr/bin/env bash
# q02 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns prod-web --ignore-not-found
rm -rf /opt/course/q02
