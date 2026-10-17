#!/usr/bin/env bash
# d09 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns spline --ignore-not-found
