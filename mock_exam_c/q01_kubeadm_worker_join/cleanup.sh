#!/usr/bin/env bash
# c01 — 실습 후 정리: worker03 의 설정을 setup 이 보관한 원본으로 되돌리고, 클러스터에 다시 들어가 있게 한다.
# 실행 (두 단계, 순서대로, 각 노드에서 root 로):
#   1) worker03:  sudo bash cleanup.sh worker   — swap 파일·fstab·모듈·sysctl·containerd 설정 원복
#   2) cp01:      sudo bash cleanup.sh cp       — 테스트 파드 삭제, 라벨 원복. join 이 안 돼 있으면 join 명령을 만들어 준다
# setup 때 NODE=<이름> 을 줬다면 여기서도 똑같이 준다.
set -euo pipefail
export KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}
NODE=${NODE:-worker03}
BK=/root/c01-backup
LABELS=/root/c01-node-labels
SWAP=/swap.c01

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }

case "${1:-}" in
worker)
  [ -d "$BK" ] || { echo "$BK 가 없습니다. setup.sh fail 을 실행한 워커에서 실행하세요"; exit 1; }

  # 1) swap — setup 이 만든 스왑 파일을 끄고 지운 뒤 fstab 원본 복원
  swapoff "$SWAP" 2>/dev/null || true
  rm -f "$SWAP"
  cp -a "$BK/fstab" /etc/fstab

  # 2) 모듈·sysctl — 보관한 파일을 그대로 되돌린다 (풀이에서 새로 만든 k8s.conf 같은 파일은 값이 맞으므로 둔다)
  cp -a "$BK/modules-load.d/." /etc/modules-load.d/
  cp -a "$BK/sysctl.d/." /etc/sysctl.d/
  if [ -f "$BK/sysctl.conf" ]; then cp -a "$BK/sysctl.conf" /etc/sysctl.conf; fi
  modprobe br_netfilter
  sysctl --system >/dev/null

  # 3) containerd 설정 원본 복원 — 내용이 달라졌을 때만 재시작
  if [ -f "$BK/config.toml" ] && ! cmp -s "$BK/config.toml" /etc/containerd/config.toml; then
    cp -a "$BK/config.toml" /etc/containerd/config.toml
    systemctl restart containerd
  fi
  rm -rf "$BK"

  swapon --show
  sysctl net.ipv4.ip_forward
  grep -n SystemdCgroup /etc/containerd/config.toml || true
  if [ -f /etc/kubernetes/kubelet.conf ]; then
    echo "$(hostname) 는 이미 join 되어 있습니다. 다음: cp01 에서 sudo bash cleanup.sh cp"
  else
    echo "$(hostname) 는 아직 join 전입니다. 다음: cp01 에서 sudo bash cleanup.sh cp → 나온 명령을 여기서 실행"
  fi
  ;;
cp)
  # 1) 풀이에서 만든 테스트 파드 t1 — 이 노드를 nodeSelector 로 고른 것만 지운다
  SEL=$(kubectl get pod t1 -o jsonpath='{.spec.nodeSelector.kubernetes\.io/hostname}' 2>/dev/null || true)
  if [ "$SEL" = "$NODE" ]; then kubectl delete pod t1 --wait=false; fi

  # 2) 노드가 join 되어 Ready 면 라벨만 원래대로
  if kubectl get node "$NODE" --no-headers 2>/dev/null | awk '{print $2}' | grep -qx Ready; then
    if [ -f "$LABELS" ]; then
      grep -qx 'node-role.kubernetes.io/worker=worker' "$LABELS" \
        || kubectl label node "$NODE" node-role.kubernetes.io/worker- 2>/dev/null || true
      while IFS= read -r kv; do
        if [ -n "$kv" ]; then kubectl label node "$NODE" "$kv" --overwrite >/dev/null; fi
      done < "$LABELS"
      rm -f "$LABELS"
    fi
    kubectl get node "$NODE" --show-labels
    echo "정리 끝"
    exit 0
  fi

  # 3) 아직 join 이 안 됐다 — NotReady 로 남은 Node 오브젝트가 있으면 지우고 join 명령을 만든다
  kubectl delete node "$NODE" --ignore-not-found
  JOIN=$(kubeadm token create --print-join-command)
  echo
  echo "== $NODE 에서 root 로 실행 (cleanup.sh worker 를 먼저 했어야 한다) =="
  echo "kubeadm reset -f && $JOIN"
  echo
  echo "== 그다음 cp01 에서 다시 실행 → 라벨 원복 =="
  echo "sudo bash cleanup.sh cp"
  ;;
*)
  echo "사용법: sudo bash cleanup.sh worker   (worker03, 먼저)"
  echo "        sudo bash cleanup.sh cp       (cp01, 그다음)"
  exit 1
  ;;
esac
