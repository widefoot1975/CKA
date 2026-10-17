#!/usr/bin/env bash
# e12 — 실습 후 정리 (tmp 네임스페이스는 이 문제만 쓴다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns tmp --ignore-not-found --wait=true
