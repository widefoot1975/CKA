#!/usr/bin/env bash
# d13 — Bring a NotReady node back · 사전 환경 설정 (worker01 의 kubelet 을 일부러 멈춘다)
# 실행: worker01 에서 sudo bash setup.sh   (여러 번 실행해도 안전)
#       또는 k8s-c1 에서 ssh worker01 'sudo bash -s' < setup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash setup.sh"; exit 1; }

# 0) worker 노드인지 확인 (컨트롤 플레인 노드에서는 하지 않는다)
[ ! -f /etc/kubernetes/manifests/kube-apiserver.yaml ] || { echo "컨트롤 플레인 노드입니다. worker 노드에서 실행하세요."; exit 1; }

# 1) 이전 실습 흔적 정리
rm -rf /opt/course/d13
mkdir -p /opt/course/d13

# 2) 고장 내기: kubelet 을 멈추고(stop) 부팅 때 자동 시작도 끈다(disable)
systemctl disable --now kubelet

# 3) 시작 상태 확인: inactive / disabled. 약 1분 뒤 k8s-c1 에서 worker01 이 NotReady 로 바뀐다
systemctl is-active kubelet || true
systemctl is-enabled kubelet || true
