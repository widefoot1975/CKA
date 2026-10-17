#!/usr/bin/env bash
# e16 — 실습 후 정리 (CoreDNS 를 kubeadm 기본값인 2개로 되돌린다)
# 실행: bash cleanup.sh
set -euo pipefail

kubectl -n kube-system scale deploy coredns --replicas=2
kubectl -n kube-system rollout status deploy coredns --timeout=120s
rm -rf /opt/course/e16
