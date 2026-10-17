#!/usr/bin/env bash
# a08 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns shop --ignore-not-found
