#!/usr/bin/env bash
# b02 — Prepare a node for joining a cluster · 사전 환경 설정
# 클러스터에 속하지 않은 빈 Ubuntu/Debian VM(문제의 worker03)에서 실행한다.
# containerd·kubelet·kubeadm·kubectl 을 설치하고, swap 을 켜고, 커널·containerd 설정을 "준비 전" 상태로 되돌린다.
# 실행: sudo bash setup.sh   (worker03 에서 root 로 실행, 여러 번 실행해도 안전)
set -euo pipefail
K8S_MINOR=v1.35          # pkgs.k8s.io 저장소의 마이너 버전
SWAPFILE=/swapfile-q02   # 이 스크립트가 만드는 swap 파일 (VM 에 swap 이 없을 때만)
FSTAB_ORIG=/root/.q02-fstab.orig
CTRD_ORIG=/root/.q02-containerd-config.orig

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }
# 클러스터 노드에서 돌리면 커널 설정을 지우고 swap 을 켜서 노드가 망가진다 — join 된 노드는 거부
if [ -f /etc/kubernetes/kubelet.conf ] || [ -f /etc/kubernetes/admin.conf ]; then
  echo "이 머신은 이미 쿠버네티스 노드입니다. 클러스터에 속하지 않은 빈 VM 에서 실행하세요"; exit 1
fi

# 1) 처음 실행할 때만 원래 설정을 보관한다 (cleanup.sh 가 이것으로 되돌린다)
[ -f "$FSTAB_ORIG" ] || cp -a /etc/fstab "$FSTAB_ORIG"
if [ ! -e "$CTRD_ORIG" ] && [ ! -e "$CTRD_ORIG.none" ]; then
  if [ -f /etc/containerd/config.toml ]; then cp -a /etc/containerd/config.toml "$CTRD_ORIG"
  else touch "$CTRD_ORIG.none"; fi                     # .none = 원래 파일이 없었다는 표시
fi

# 2) 패키지 (문제의 전제 조건) — 없을 때만 설치. containerd.io(Docker 저장소)가 있으면 그대로 쓴다
export DEBIAN_FRONTEND=noninteractive
apt-mark unhold kubelet kubeadm kubectl >/dev/null 2>&1 || true
if ! command -v containerd >/dev/null || ! command -v kubeadm >/dev/null; then
  apt-get update -q
  apt-get install -y -q ca-certificates curl gpg
  command -v containerd >/dev/null || apt-get install -y -q containerd
  if ! command -v kubeadm >/dev/null; then
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/$K8S_MINOR/deb/Release.key \
      | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$K8S_MINOR/deb/ /" \
      > /etc/apt/sources.list.d/kubernetes.list
    apt-get update -q
    apt-get install -y -q kubelet kubeadm kubectl      # cri-tools(crictl) 도 함께 설치된다
  fi
fi

# 3) 지난 실습 흔적 정리: 모듈·sysctl 설정 파일, 지금 켜진 값
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/k8s.conf
modprobe -r br_netfilter 2>/dev/null || true          # 쓰는 곳이 있으면 내려가지 않는다 (무시)
sysctl -qw net.ipv4.ip_forward=0 2>/dev/null || true  # 빈 VM 은 라우터가 아니므로 0 이 기본값
sysctl -q --system >/dev/null 2>&1 || true

# 4) containerd 를 기본 설정(cgroupfs = SystemdCgroup false)으로
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = true/SystemdCgroup = false/' /etc/containerd/config.toml
systemctl enable --now containerd >/dev/null 2>&1
systemctl restart containerd

# 5) swap 켜기 — 지난 실습에서 주석 처리한 fstab 을 되돌리고, 그래도 swap 이 없으면 작은 swap 파일을 만든다
cp -a "$FSTAB_ORIG" /etc/fstab
for u in $(systemctl list-unit-files --type=swap --state=masked --no-legend 2>/dev/null | awk '{print $1}'); do
  systemctl unmask "$u" >/dev/null
done
systemctl daemon-reload
swapon -a 2>/dev/null || true
if [ -z "$(swapon --noheadings)" ]; then
  [ -f "$SWAPFILE" ] || { fallocate -l 512M "$SWAPFILE" || dd if=/dev/zero of="$SWAPFILE" bs=1M count=512 status=none; }
  chmod 600 "$SWAPFILE"
  mkswap "$SWAPFILE" >/dev/null
  swapon "$SWAPFILE"
fi
if [ -f "$SWAPFILE" ] && ! grep -q "^$SWAPFILE " /etc/fstab; then
  echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
fi

# 6) 답 디렉터리
mkdir -p /opt/q02
rm -f /opt/q02/cgroup.txt

# 7) 시작 상태 확인: swap 켜짐, 설정 파일 없음, SystemdCgroup false, 패키지 고정 안 됨
swapon --show
ls /etc/modules-load.d/ /etc/sysctl.d/
sysctl net.ipv4.ip_forward
grep -n 'SystemdCgroup' /etc/containerd/config.toml
echo "hold: $(apt-mark showhold | tr '\n' ' ')"
systemctl is-active containerd
