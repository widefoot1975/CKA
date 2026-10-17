#!/usr/bin/env bash
# e14 — Node NotReady because the container runtime is down · 사전 환경 설정 (worker02 의 containerd 를 일부러 멈춘다)
# 실행: worker02 에서 sudo bash setup.sh   (여러 번 실행해도 안전)
#       또는 k8s-c1 에서 ssh worker02 'sudo bash -s' < setup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash setup.sh"; exit 1; }

# 0) worker 노드인지 확인 (컨트롤 플레인 노드에서는 하지 않는다)
[ ! -f /etc/kubernetes/manifests/kube-apiserver.yaml ] || { echo "컨트롤 플레인 노드입니다. worker 노드에서 실행하세요."; exit 1; }

# 1) 이전 실습 흔적 정리 (kubelet 은 켜져 있어야 한다)
rm -rf /opt/course/e14
mkdir -p /opt/course/e14
systemctl enable --now kubelet

# 2) 고장 내기: containerd 를 멈추고(stop) 부팅 때 자동 시작도 끈다(disable)
#    containerd 유닛은 KillMode=process 라서 이미 떠 있는 컨테이너는 그대로 돈다
systemctl disable --now containerd

# 3) 시작 상태 확인: kubelet active, containerd inactive / disabled. 약 1분 뒤 worker02 가 NotReady
systemctl is-active kubelet
systemctl is-active containerd || true
systemctl is-enabled containerd || true
