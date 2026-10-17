#!/usr/bin/env bash
# c08 — 실습 후 정리 (NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 남겨 둔다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns gateway-system shop --ignore-not-found
