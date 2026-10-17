#!/usr/bin/env bash
# f02 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete clusterrolebinding anna-deploy-view --ignore-not-found
kubectl delete clusterrole deployment-viewer --ignore-not-found
kubectl delete ns team-a team-b --ignore-not-found
