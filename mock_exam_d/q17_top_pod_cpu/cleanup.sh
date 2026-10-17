#!/usr/bin/env bash
# d17 — 실습 후 정리 (metrics-server 는 다른 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns batch --ignore-not-found
rm -rf /opt/course/d17
