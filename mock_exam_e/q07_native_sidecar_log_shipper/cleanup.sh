#!/usr/bin/env bash
# e07 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns synergy --ignore-not-found
