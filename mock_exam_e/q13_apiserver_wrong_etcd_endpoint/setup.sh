#!/usr/bin/env bash
# e13 — API server down after a machine migration · 사전 환경 설정 (kube-apiserver 의 etcd 주소를 일부러 옛 머신 주소로)
# 실행: cp01 에서 sudo bash setup.sh   (여러 번 실행해도 안전)
#       또는 k8s-c2 에서 ssh cp01 'sudo bash -s' < setup.sh
# 주의: 실행하면 이 클러스터의 kubectl 이 전부 멈춘다. 풀거나 cleanup.sh 를 돌려야 돌아온다.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash setup.sh"; exit 1; }
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 매니페스트 보관 위치 (반드시 매니페스트 디렉터리 밖)
[ -f $MAN/kube-apiserver.yaml ] || { echo "$MAN/kube-apiserver.yaml 이 없습니다. 컨트롤 플레인 노드에서 실행하세요."; exit 1; }

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (A17 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-apiserver.yaml ] || cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml
rm -rf /opt/course/e13
mkdir -p /opt/course/e13

# 1) 원래 값 확인 (kubeadm stacked etcd 라면 https://127.0.0.1:2379) 후 원본 보관
ORIG=$(grep -o -- '--etcd-servers=[^ ]*' $MAN/kube-apiserver.yaml | cut -d= -f2)
[ -n "$ORIG" ] || { echo "--etcd-servers 를 찾지 못했습니다."; exit 1; }
echo "원래 --etcd-servers: $ORIG"
[ "$ORIG" = https://127.0.0.1:2379 ] || echo "주의: 127.0.0.1 이 아닙니다. 풀 때는 원래 값($ORIG)으로 되돌려야 합니다."
cp $MAN/kube-apiserver.yaml $KEEP/kube-apiserver.yaml

# 2) 고장 내기: 옛 머신 주소로 바꾼다 (이 노드의 주소와 겹치면 다른 값을 쓴다)
OLD=10.0.5.20
hostname -I | tr ' ' '\n' | grep -qx $OLD && OLD=10.0.6.20
sed -i "s#--etcd-servers=.*#--etcd-servers=https://$OLD:2379#" $MAN/kube-apiserver.yaml

# 3) 시작 상태 확인: 1~2분 뒤 kubectl 은 connection refused, crictl ps -a 에 Exited kube-apiserver
grep -n -- '--etcd-servers' $MAN/kube-apiserver.yaml
