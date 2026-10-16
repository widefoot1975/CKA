#!/usr/bin/env bash
# d12 — 실습 후 정리 (local-path 프로비저너는 다른 Storage 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns data --ignore-not-found
