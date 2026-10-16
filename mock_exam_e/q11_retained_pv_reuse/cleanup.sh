#!/usr/bin/env bash
# e11 — 실습 후 정리 (Retain PV 는 직접 지워야 한다. 노드의 /srv/ledger-pv 디렉터리는 남는다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete ns finance --ignore-not-found --wait=true
kubectl delete pv ledger-pv --ignore-not-found
rm -rf /opt/course/e11
