#!/usr/bin/env bash
# a02 — 실습 후 정리
# 업그레이드는 되돌릴 수 없다 (kubeadm 은 컨트롤 플레인 다운그레이드를 지원하지 않는다).
# 다시 연습하려면 업그레이드 전에 찍어 둔 VM 스냅샷으로 되돌리거나 클러스터를 한 마이너 낮게 다시 만든다.
# 이 스크립트는 중간에 그만둬서 cordon 이 남은 노드만 풀어 준다.
# 실행: bash cleanup.sh   (k8s-c2 에서 실행)
set -euo pipefail

for n in $(kubectl get nodes -o jsonpath='{range .items[?(@.spec.unschedulable==true)]}{.metadata.name}{" "}{end}'); do
  kubectl uncordon "$n"
done
kubectl get nodes
