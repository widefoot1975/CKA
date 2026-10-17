#!/usr/bin/env bash
# d05 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns shop --ignore-not-found
