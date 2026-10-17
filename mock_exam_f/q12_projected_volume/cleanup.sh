#!/usr/bin/env bash
# f12 — 실습 후 정리 (namespace proj 는 D10 도 쓰므로 이 문제의 리소스만 지운다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl -n proj delete pod projected-demo --ignore-not-found
kubectl -n proj delete secret db-cred --ignore-not-found
kubectl -n proj delete cm app-cfg --ignore-not-found
