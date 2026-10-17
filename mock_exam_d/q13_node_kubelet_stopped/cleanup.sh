#!/usr/bin/env bash
# d13 — 실습 후 정리 (kubelet 을 다시 켜고 부팅 시 자동 시작도 켠다)
# 실행: worker01 에서 sudo bash cleanup.sh
#       또는 k8s-c1 에서 ssh worker01 'sudo bash -s' < cleanup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash cleanup.sh"; exit 1; }

systemctl enable --now kubelet
rm -rf /opt/course/d13
systemctl is-active kubelet
systemctl is-enabled kubelet
