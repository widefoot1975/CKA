#!/usr/bin/env bash
# e01 — 실습 후 정리 (cri-dockerd 와 이 문제에서 만든 설정 파일을 지운다. Docker 와 crictl 은 남긴다)
# 실행: sudo bash cleanup.sh   (worker03 에서 root 로 실행)
set -euo pipefail

systemctl disable --now cri-docker.service cri-docker.socket 2>/dev/null || true
dpkg -P cri-dockerd 2>/dev/null || true
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/k8s.conf /root/cri-dockerd.deb
sysctl --system >/dev/null
