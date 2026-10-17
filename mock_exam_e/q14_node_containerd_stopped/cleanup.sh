#!/usr/bin/env bash
# e14 — 실습 후 정리 (containerd 를 다시 켜고 부팅 시 자동 시작도 켠다)
# 실행: worker02 에서 sudo bash cleanup.sh
#       또는 k8s-c1 에서 ssh worker02 'sudo bash -s' < cleanup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash cleanup.sh"; exit 1; }

systemctl enable --now containerd
# kubelet 을 그사이 재시작해서 auto-restart 반복에 빠졌으면 다시 띄운다
systemctl is-active --quiet kubelet || systemctl restart kubelet
rm -rf /opt/course/e14
systemctl is-active containerd kubelet
systemctl is-enabled containerd
