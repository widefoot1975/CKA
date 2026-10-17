#!/usr/bin/env bash
# b02 — 실습 후 정리 (이 문제에서 만든 설정을 지우고 fstab·containerd 설정을 setup 이전으로 되돌린다.
#        containerd 와 kubelet·kubeadm·kubectl 패키지는 남긴다)
# 실행: sudo bash cleanup.sh   (worker03 에서 root 로 실행)
set -euo pipefail
SWAPFILE=/swapfile-q02
FSTAB_ORIG=/root/.q02-fstab.orig
CTRD_ORIG=/root/.q02-containerd-config.orig

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }

# 1) 패키지 고정 풀기, 모듈·sysctl 설정 파일 지우기
apt-mark unhold kubelet kubeadm kubectl >/dev/null 2>&1 || true
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/k8s.conf
sysctl -q --system >/dev/null 2>&1 || true

# 2) swap — setup 이 만든 swap 파일을 지우고, fstab 을 원래대로 돌려 원래 있던 swap 을 다시 켠다
swapoff "$SWAPFILE" 2>/dev/null || true
rm -f "$SWAPFILE"
if [ -f "$FSTAB_ORIG" ]; then cp -a "$FSTAB_ORIG" /etc/fstab; rm -f "$FSTAB_ORIG"; fi
for u in $(systemctl list-unit-files --type=swap --state=masked --no-legend 2>/dev/null | awk '{print $1}'); do
  systemctl unmask "$u" >/dev/null
done
systemctl daemon-reload
swapon -a 2>/dev/null || true

# 3) containerd 설정 — setup 이전 파일로 되돌린다 (원래 없었으면 지운다)
if [ -f "$CTRD_ORIG.none" ]; then
  rm -f /etc/containerd/config.toml "$CTRD_ORIG.none"
elif [ -f "$CTRD_ORIG" ]; then
  cp -a "$CTRD_ORIG" /etc/containerd/config.toml; rm -f "$CTRD_ORIG"
fi
systemctl restart containerd 2>/dev/null || true

# 4) 답 디렉터리
rm -rf /opt/q02
