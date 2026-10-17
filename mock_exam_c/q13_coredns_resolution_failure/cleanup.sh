#!/usr/bin/env bash
# c13 — 실습 후 정리 (Corefile 을 setup 이 보관한 원본으로 되돌린다. 남겨 두면 클러스터 전체의 DNS 가 계속 멈춰 있음)
# 실행: bash cleanup.sh
set -euo pipefail

ORIG=/opt/course/c13-corefile.orig
if [ -f "$ORIG" ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile="$ORIG" --dry-run=client -o yaml | kubectl replace -f -
  kubectl -n kube-system rollout restart deploy coredns
  kubectl -n kube-system rollout status deploy coredns --timeout=120s
  rm -f "$ORIG"
fi

# namespace app 은 이 문제가 만든 것(라벨 course=c13)일 때만 지운다. f09 가 만든 것이면 이 문제 리소스만 지운다.
kubectl -n app delete deploy,svc -l course=c13 --ignore-not-found
if [ "$(kubectl get ns app -o jsonpath='{.metadata.labels.course}' 2>/dev/null || true)" = "c13" ]; then
  kubectl delete ns app --ignore-not-found
fi
rm -rf /opt/course/q13
