#!/usr/bin/env bash
# a11 — 실습 후 정리 (ops namespace 는 다른 문제도 쓰므로 남긴다. Retain PV 는 직접 지워야 한다)
# 실행: bash cleanup.sh   (k8s-c1 에서 실행)
set -euo pipefail

kubectl -n ops delete pod logger --ignore-not-found --wait=true
kubectl -n ops delete pvc pvc-logs pvc-logs-2 --ignore-not-found --wait=true
kubectl delete pv pv-logs --ignore-not-found --wait=true
# worker01 의 /mnt/data/logs 는 남는다. 지우려면 worker01 에서: sudo rm -rf /mnt/data/logs
