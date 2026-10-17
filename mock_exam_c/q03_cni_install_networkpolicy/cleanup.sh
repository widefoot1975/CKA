#!/usr/bin/env bash
# c03 — 실습 후 정리
# 설치한 CNI 는 지우지 않는다 — 클러스터의 파드 네트워크가 그 CNI 에 달려 있다.
# 처음부터 다시 연습하려면 CNI 를 깔기 전에 찍어 둔 VM 스냅샷으로 되돌리거나, 모든 노드에서 kubeadm reset 후 다시 만든다.
# 실행: bash cleanup.sh   (k8s-c4 에서 실행)
set -euo pipefail

kubectl delete ns cni-test --ignore-not-found
rm -rf /opt/course/q03
