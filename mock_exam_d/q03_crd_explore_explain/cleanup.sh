#!/usr/bin/env bash
# d03 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

rm -rf /opt/course/d03
# cert-manager 까지 지우려면 아래 주석을 해제 (다른 문제에서 쓰면 남겨 둘 것)
# kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml --ignore-not-found
