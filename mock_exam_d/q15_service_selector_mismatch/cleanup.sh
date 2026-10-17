#!/usr/bin/env bash
# d15 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns store --ignore-not-found
