#!/usr/bin/env bash
# b09 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns payments frontend scanner --ignore-not-found
