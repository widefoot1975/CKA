#!/usr/bin/env bash
# e10 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns api --ignore-not-found
