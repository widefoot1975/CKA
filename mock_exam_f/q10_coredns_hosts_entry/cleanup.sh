#!/usr/bin/env bash
# f10 — 실습 후 정리 (Corefile 을 setup 이 보관한 원본으로 되돌린다. 남겨 두면 모든 파드가 db.internal 을 계속 해석함)
# 실행: bash cleanup.sh
set -euo pipefail

ORIG=/opt/course/f10-corefile.orig
if [ -f "$ORIG" ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile="$ORIG" --dry-run=client -o yaml | kubectl replace -f -
  kubectl -n kube-system rollout restart deploy coredns
  kubectl -n kube-system rollout status deploy coredns --timeout=120s
  rm -f "$ORIG"
fi
rm -rf /opt/course/f10
