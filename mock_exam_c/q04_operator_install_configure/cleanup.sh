#!/usr/bin/env bash
# c04 — 실습 후 정리 (CRD 를 지우면 Backup 오브젝트도 함께 지워진다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns backup-system --ignore-not-found
kubectl delete crd backups.telco.io --ignore-not-found
kubectl delete clusterrolebinding backup-operator --ignore-not-found
kubectl delete clusterrole backup-operator backup-viewer --ignore-not-found
kubectl -n default delete rolebinding viewer-test --ignore-not-found
kubectl -n default delete serviceaccount viewer-test --ignore-not-found
rm -rf /opt/course/q04
