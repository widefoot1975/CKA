#!/usr/bin/env bash
# e01 — Install cri-dockerd and set kernel parameters · 사전 환경 설정
# 클러스터에 속하지 않은 빈 Ubuntu/Debian VM(문제의 worker03)에서 실행한다.
# Docker Engine 을 설치하고, 설치할 패키지 /root/cri-dockerd.deb 를 준비하고, 지난 실습의 설정을 지운다.
# 실행: sudo bash setup.sh   (worker03 에서 root 로 실행, 여러 번 실행해도 안전)
set -euo pipefail
CRID_VER=0.3.16          # cri-dockerd 릴리스 (github.com/Mirantis/cri-dockerd/releases)
CRICTL_VER=v1.35.0       # crictl 릴리스 (github.com/kubernetes-sigs/cri-tools/releases)

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }
# 클러스터 노드에서 돌리면 커널 설정을 지워 노드가 망가진다 — kubelet 이 도는 노드는 거부
if systemctl is-active --quiet kubelet || [ -f /etc/kubernetes/kubelet.conf ]; then
  echo "이 머신은 이미 쿠버네티스 노드입니다. 클러스터에 속하지 않은 빈 VM 에서 실행하세요"; exit 1
fi
ARCH=$(dpkg --print-architecture)        # amd64 / arm64

# 1) Docker Engine (문제의 전제 조건) — 없을 때만 설치
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh
systemctl enable --now docker

# 2) crictl — 없을 때만 설치
if ! command -v crictl >/dev/null; then
  curl -fsSL https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VER/crictl-$CRICTL_VER-linux-$ARCH.tar.gz \
    | tar -xz -C /usr/local/bin crictl
fi

# 3) 지난 실습 흔적 정리: cri-dockerd 패키지, 모듈·sysctl 설정 파일
systemctl disable --now cri-docker.service cri-docker.socket 2>/dev/null || true
dpkg -P cri-dockerd 2>/dev/null || true
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/k8s.conf
modprobe -r br_netfilter 2>/dev/null || true          # Docker 가 쓰고 있으면 내려가지 않는다 (무시)
sysctl -qw net.netfilter.nf_conntrack_max=65536 2>/dev/null || true

# 4) /root/cri-dockerd.deb 만들기 — 공식 바이너리 + 공식 systemd 유닛을 .deb 로 묶는다
#    (공식 .deb 는 배포판 코드명마다 파일이 달라서, 어느 Ubuntu/Debian 에서도 쓰도록 직접 묶는다)
W=$(mktemp -d)
curl -fsSL https://github.com/Mirantis/cri-dockerd/releases/download/v$CRID_VER/cri-dockerd-$CRID_VER.$ARCH.tgz \
  | tar -xz -C "$W"
mkdir -p "$W/pkg/DEBIAN" "$W/pkg/usr/bin" "$W/pkg/lib/systemd/system"
install -m 0755 "$W/cri-dockerd/cri-dockerd" "$W/pkg/usr/bin/cri-dockerd"
for u in cri-docker.service cri-docker.socket; do
  curl -fsSL https://raw.githubusercontent.com/Mirantis/cri-dockerd/v$CRID_VER/packaging/systemd/$u \
    -o "$W/pkg/lib/systemd/system/$u"
done
cat > "$W/pkg/DEBIAN/control" <<CTRL
Package: cri-dockerd
Version: $CRID_VER
Architecture: $ARCH
Maintainer: CKA practice <none@example.com>
Description: cri-dockerd $CRID_VER (CKA practice package)
CTRL
dpkg-deb --build --root-owner-group "$W/pkg" /root/cri-dockerd.deb >/dev/null
rm -rf "$W"

# 5) 시작 상태 확인: Docker 동작, cri-dockerd 는 미설치, 설정 파일 없음
docker version --format 'Docker {{.Server.Version}}'
ls -l /root/cri-dockerd.deb
dpkg -l cri-dockerd 2>/dev/null | grep -q '^ii' && echo "cri-dockerd: installed (?)" || echo "cri-dockerd: not installed"
ls /etc/modules-load.d/ /etc/sysctl.d/
