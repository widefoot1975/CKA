#!/usr/bin/env bash
# a07 — Taints, tolerations and node affinity · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 노드 worker02 가 있는지 확인
kubectl get node worker02

# 1) 이전 실습 흔적 정리 (파드, taint, tier 라벨)
kubectl -n default delete pod batch-runner web-front --ignore-not-found --wait=true
kubectl taint node worker02 workload=batch:NoSchedule- 2>/dev/null || true
kubectl label nodes -l 'tier in (batch,web)' tier- 2>/dev/null || true

# 2) 설정 확인: worker02 에 workload taint 가 없고, tier 라벨이 붙은 노드가 없어야 함
kubectl describe node worker02 | grep -A2 Taints
kubectl get nodes -L tier
