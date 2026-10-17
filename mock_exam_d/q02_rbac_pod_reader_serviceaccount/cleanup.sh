#!/usr/bin/env bash
# d02 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns apps --ignore-not-found
