#!/usr/bin/env bash
# b06 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns team-a --ignore-not-found
rm -rf /opt/q06
