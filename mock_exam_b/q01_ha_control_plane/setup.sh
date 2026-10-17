#!/usr/bin/env bash
# b01 — Verify and operate a highly-available control plane · 사전 환경 설정
# 컨트롤 플레인 3대(stacked etcd) 클러스터에서 "cp03 이 죽고 reset 없이 재설치된" 상태를 만든다.
# 실행 (두 단계, 각 노드에서 root 로):
#   1) cp01:  sudo bash setup.sh prepare     — 점검, etcdctl 준비, 답 디렉터리
#   2) cp03:  sudo bash setup.sh fail        — cp03 을 지운다 (etcd 멤버와 Node 오브젝트는 남긴다)
set -euo pipefail
export KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }

case "${1:-}" in
prepare)
  # 1) 컨트롤 플레인 3대 이상인 HA 클러스터인지
  N=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers | wc -l)
  if [ "$N" -lt 3 ]; then
    echo "컨트롤 플레인이 ${N}대입니다. 이 문제는 3대짜리 HA 클러스터가 있어야 연습할 수 있습니다"; exit 1
  fi

  # 2) etcdctl — 호스트에 없으면 etcd 파드와 같은 버전을 설치
  if ! command -v etcdctl >/dev/null; then
    VER=$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].spec.containers[0].image}' \
          | sed -E 's/.*:v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    ARCH=$(dpkg --print-architecture 2>/dev/null || echo amd64)
    curl -fsSL https://github.com/etcd-io/etcd/releases/download/v$VER/etcd-v$VER-linux-$ARCH.tar.gz \
      | tar -xz -C /usr/local/bin --strip-components=1 etcd-v$VER-linux-$ARCH/etcdctl
  fi

  # 3) 이전 실습 흔적 정리 — 답 디렉터리
  rm -rf /opt/q01
  mkdir -p /opt/q01

  # 4) 시작 전 상태: 멤버 3개 모두 started
  ETCDCTL_ENDPOINTS=https://127.0.0.1:2379 ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
  ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
    etcdctl member list -w table
  kubectl get nodes -l node-role.kubernetes.io/control-plane
  echo "다음: cp03 에서 sudo bash setup.sh fail"
  ;;
fail)
  # cp03 이 "죽고 kubeadm reset 없이 새로 설치된" 상태를 흉내 낸다.
  # kubeadm reset 에서 etcd 멤버를 지우는 단계만 건너뛰면, 노드는 깨끗해지고 클러스터에는 옛 멤버가 남는다.
  [ -f /etc/kubernetes/manifests/etcd.yaml ] || { echo "stacked etcd 가 도는 컨트롤 플레인 노드(cp03)에서 실행하세요"; exit 1; }
  read -r -p "$(hostname) 의 쿠버네티스 설정을 모두 지웁니다. 계속하려면 yes 입력: " ans
  [ "$ans" = yes ] || { echo "취소했습니다"; exit 1; }
  kubeadm reset -f --skip-phases=remove-etcd-member
  rm -rf /etc/cni/net.d/* "$HOME/.kube"
  echo "완료. cp01 에서 etcdctl member list 를 보면 $(hostname) 멤버가 아직 남아 있다"
  ;;
*)
  echo "사용법: sudo bash setup.sh prepare   (cp01)"
  echo "        sudo bash setup.sh fail      (cp03)"
  exit 1
  ;;
esac
