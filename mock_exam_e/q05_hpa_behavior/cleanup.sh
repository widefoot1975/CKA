#!/usr/bin/env bash
# e05 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns autoscale --ignore-not-found
# metrics-server 는 다른 문제(kubectl top 등)에서도 쓰므로 남겨 둔다
