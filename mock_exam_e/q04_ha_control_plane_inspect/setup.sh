#!/usr/bin/env bash
# e04 — Inspect a highly-available control plane · 사전 환경 설정
# 정보 수집 문제라 만들 리소스는 없다. 답 디렉터리를 비우고, etcdctl 을 준비하고, 클러스터 모양을 확인한다.
# 실행: sudo bash setup.sh   (cp01 에서 root 로 실행, 여러 번 실행해도 안전)
set -euo pipefail
export KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }
[ -f /etc/kubernetes/pki/etcd/server.crt ] || { echo "stacked etcd 가 있는 컨트롤 플레인 노드(cp01)에서 실행하세요"; exit 1; }

# 1) 이전 실습 흔적 정리
rm -rf /opt/course/e04
mkdir -p /opt/course/e04

# 2) etcdctl — 호스트에 없으면 etcd 파드와 같은 버전을 /usr/local/bin 에 설치
if ! command -v etcdctl >/dev/null; then
  IMG=$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].spec.containers[0].image}')
  VER=$(echo "$IMG" | sed -E 's/.*:v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/')       # registry.k8s.io/etcd:3.6.5-0 → 3.6.5
  ARCH=$(dpkg --print-architecture 2>/dev/null || echo amd64)
  curl -fsSL https://github.com/etcd-io/etcd/releases/download/v$VER/etcd-v$VER-linux-$ARCH.tar.gz \
    | tar -xz -C /usr/local/bin --strip-components=1 etcd-v$VER-linux-$ARCH/etcdctl
fi
etcdctl version | head -1

# 3) 클러스터 모양 확인 — 컨트롤 플레인 노드 수와 controlPlaneEndpoint
N=$(kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers | wc -l)
EP=$(kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' \
     | awk '/controlPlaneEndpoint/ {print $2}')
echo "컨트롤 플레인 노드: $N 대 / controlPlaneEndpoint: ${EP:-(없음)}"
[ "$N" -ge 3 ] || echo "※ HA 가 아닌 클러스터입니다. 같은 명령으로 풀 수 있지만 답(노드 이름, 멤버 수)은 ${N}개가 됩니다"
[ -n "$EP" ] || echo "※ kubeadm init 때 --control-plane-endpoint 를 주지 않아 값이 비어 있습니다. 이 경우 endpoint.txt 는 빈 파일이 정답입니다"
kubectl -n kube-system get pods -l component=etcd -o wide
