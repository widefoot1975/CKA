#!/usr/bin/env bash
# c01 — Join a new worker node to the cluster · 사전 환경 설정
# 이미 join 된 워커 하나를 클러스터에서 빼고 kubeadm reset 해서 "새로 준비된, 아직 join 안 한 머신"으로 만든 뒤
# 노드 전제조건 네 가지(swap, br_netfilter, ip_forward, SystemdCgroup)를 일부러 틀어 둔다.
# 실행 (두 단계, 각 노드에서 root 로):
#   1) cp01:      sudo bash setup.sh prepare   — 노드 drain, 라벨 보관, Node 오브젝트 삭제
#   2) worker03:  sudo bash setup.sh fail      — kubeadm reset, 원본 설정 보관, 전제조건 틀기
# 워커 이름이 worker03 이 아니면 두 단계 모두 NODE=<이름> 을 앞에 붙인다 (예: sudo NODE=worker02 bash setup.sh prepare)
set -euo pipefail
export KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}
NODE=${NODE:-worker03}
BK=/root/c01-backup            # worker 쪽 원본 설정 보관 위치
LABELS=/root/c01-node-labels   # cp01 쪽 원래 노드 라벨 보관 위치
SWAP=/swap.c01

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }

case "${1:-}" in
prepare)
  # 이미 prepare 를 했다면(노드가 없고 라벨 보관 파일이 있으면) 건너뛴다
  if ! kubectl get node "$NODE" >/dev/null 2>&1; then
    [ -f "$LABELS" ] && { echo "$NODE 는 이미 클러스터에서 빠져 있습니다. 다음: $NODE 에서 sudo bash setup.sh fail"; exit 0; }
    echo "노드 $NODE 가 없습니다. 워커 이름을 NODE=<이름> 으로 지정하세요"; kubectl get nodes; exit 1
  fi
  if kubectl get node "$NODE" -o jsonpath='{.metadata.labels}' | grep -q 'node-role.kubernetes.io/control-plane'; then
    echo "$NODE 는 컨트롤 플레인입니다. 워커 노드를 지정하세요"; exit 1
  fi

  # 1) 원래 라벨 보관 — cleanup 이 다시 붙인다 (kubelet 이 스스로 붙이는 kubernetes.io/ 계열은 제외)
  kubectl get node "$NODE" -o go-template='{{range $k,$v := .metadata.labels}}{{$k}}={{$v}}{{"\n"}}{{end}}' \
    | grep -Ev '^(kubernetes\.io/|beta\.kubernetes\.io/|node\.kubernetes\.io/)' > "$LABELS" || true

  # 2) 파드를 다른 노드로 옮기고 Node 오브젝트 삭제
  kubectl drain "$NODE" --ignore-daemonsets --delete-emptydir-data --force --timeout=180s
  kubectl delete node "$NODE"

  kubectl get nodes
  echo "다음: $NODE 에서 sudo bash setup.sh fail"
  ;;
fail)
  # 1) kubeadm reset — 이미 reset 된 상태면 건너뛴다
  if [ -f /etc/kubernetes/kubelet.conf ]; then
    [ -f /etc/kubernetes/manifests/kube-apiserver.yaml ] && { echo "컨트롤 플레인 노드입니다. 워커($NODE)에서 실행하세요"; exit 1; }
    read -r -p "$(hostname) 를 kubeadm reset 해서 클러스터에서 뺍니다. cp01 에서 prepare 를 먼저 했나요? 계속하려면 yes 입력: " ans
    [ "$ans" = yes ] || { echo "취소했습니다"; exit 1; }
    kubeadm reset -f
    rm -rf /etc/cni/net.d/* "$HOME/.kube"
  fi

  # 2) 원본 설정 보관 — 처음 한 번만 (다시 실행해도 원본을 덮어쓰지 않는다)
  if [ ! -d "$BK" ]; then
    mkdir -p "$BK"
    cp -a /etc/fstab "$BK/fstab"
    if [ -f /etc/containerd/config.toml ]; then cp -a /etc/containerd/config.toml "$BK/config.toml"; fi
    if [ -f /etc/sysctl.conf ]; then cp -a /etc/sysctl.conf "$BK/sysctl.conf"; fi
    cp -a /etc/sysctl.d "$BK/sysctl.d"
    cp -a /etc/modules-load.d "$BK/modules-load.d"
  fi

  # 3) 전제조건 틀기 ① swap — 256MiB 스왑 파일을 켜고 fstab 에도 등록
  if [ ! -f "$SWAP" ]; then
    dd if=/dev/zero of="$SWAP" bs=1M count=256 status=none
    chmod 600 "$SWAP"
    mkswap "$SWAP" >/dev/null
  fi
  swapon --show=NAME --noheadings | grep -qx "$SWAP" || swapon "$SWAP"
  grep -q "^$SWAP " /etc/fstab || echo "$SWAP none swap sw 0 0" >> /etc/fstab

  # ② br_netfilter — 부팅 시 로드 설정을 주석 처리하고 모듈을 내린다
  sed -i -E 's/^[[:space:]]*br_netfilter/#br_netfilter/' /etc/modules-load.d/*.conf 2>/dev/null || true
  modprobe -r br_netfilter 2>/dev/null || true

  # ③ ip_forward — 1 로 켜는 줄을 주석 처리하고 지금 값을 0 으로
  for f in /etc/sysctl.conf /etc/sysctl.d/*.conf; do
    if [ -f "$f" ]; then sed -i -E 's/^([[:space:]]*net\.ipv4\.ip_forward[[:space:]]*=[[:space:]]*1)/#\1/' "$f"; fi
  done
  sysctl -qw net.ipv4.ip_forward=0

  # ④ SystemdCgroup — true 를 false 로
  if grep -q 'SystemdCgroup *= *true' /etc/containerd/config.toml 2>/dev/null; then
    sed -i 's/SystemdCgroup *= *true/SystemdCgroup = false/' /etc/containerd/config.toml
    systemctl restart containerd
  elif ! grep -q 'SystemdCgroup' /etc/containerd/config.toml 2>/dev/null; then
    echo "주의: /etc/containerd/config.toml 에 SystemdCgroup 줄이 없습니다 (풀이의 containerd config default 단계로 만든다)"
  fi

  # 4) 시작 상태 확인
  echo "== $(hostname) 시작 상태 =="
  swapon --show
  lsmod | grep -q '^br_netfilter' && echo "br_netfilter: loaded" || echo "br_netfilter: not loaded"
  sysctl net.ipv4.ip_forward
  grep -n SystemdCgroup /etc/containerd/config.toml 2>/dev/null || true
  ls /etc/kubernetes/kubelet.conf 2>/dev/null || echo "kubelet.conf 없음 (아직 join 안 됨)"
  ;;
*)
  echo "사용법: sudo bash setup.sh prepare   (cp01)"
  echo "        sudo bash setup.sh fail      (worker03)"
  exit 1
  ;;
esac
