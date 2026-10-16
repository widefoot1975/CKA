#!/usr/bin/env bash
# d10 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns proj --ignore-not-found
