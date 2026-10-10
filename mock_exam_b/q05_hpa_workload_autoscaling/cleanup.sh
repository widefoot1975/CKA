#!/usr/bin/env bash
# b05 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns web --ignore-not-found
rm -rf /opt/q05
# metrics-server 는 다른 문제(kubectl top 등)에서도 쓰므로 남겨 둔다
