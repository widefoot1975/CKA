#!/usr/bin/env bash
# q17 — 실습 후 정리
# 실행: bash cleanup.sh
# metrics-server 는 다른 문제도 쓰므로 지우지 않는다.
set -euo pipefail

kubectl delete ns perf --ignore-not-found
rm -rf /opt/course/f17
