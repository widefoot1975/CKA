#!/usr/bin/env bash
# f14 — 실습 후 정리 (~/.kube/config 를 setup 이 보관한 원본으로 되돌린다)
# 실행: bash cleanup.sh
set -euo pipefail

ORIG=$HOME/.kube/config.f14.orig
if [ -f "$ORIG" ]; then mv "$ORIG" "$HOME/.kube/config"; fi
rm -rf /opt/course/f14
kubectl get nodes
