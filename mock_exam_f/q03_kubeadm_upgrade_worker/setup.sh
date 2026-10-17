#!/usr/bin/env bash
# f03 — Upgrade one worker node with kubeadm · 사전 환경 설정
# worker01 의 kubeadm·kubelet·kubectl 을 컨트롤 플레인보다 한 마이너 낮은 버전으로 내려 둔다.
# 실행: sudo bash setup.sh   (worker01 에서 root 로 실행, 여러 번 실행해도 안전)
set -euo pipefail
LIST=/etc/apt/sources.list.d/kubernetes.list

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }
[ -f /etc/kubernetes/kubelet.conf ] || { echo "클러스터에 join 된 워커 노드(worker01)에서 실행하세요"; exit 1; }
grep -q 'pkgs.k8s.io/core:/stable:/v' $LIST || { echo "$LIST 에 pkgs.k8s.io 저장소가 없습니다"; exit 1; }

# 1) 컨트롤 플레인 버전 확인 (/version 은 노드 자격 증명으로도 읽힌다)
CP=$(kubectl --kubeconfig /etc/kubernetes/kubelet.conf get --raw /version \
     | grep -o '"gitVersion": *"v[0-9.]*' | grep -o '[0-9][0-9.]*')
CUR=$(echo "$CP" | cut -d. -f1,2)                                  # 예: 1.35
PREV=$(echo "$CUR" | awk -F. '{printf "%d.%d", $1, $2-1}')          # 예: 1.34
echo "컨트롤 플레인 v$CP → worker01 을 v$PREV 로 내린다"

# 2) 저장소를 한 마이너 낮은 버전으로 바꾸고 그 버전의 최신 패치를 설치 (다운그레이드)
sed -i -E "s#core:/stable:/v[0-9]+\.[0-9]+/#core:/stable:/v$PREV/#" $LIST
apt-get update -qq
OLD=$(apt-cache madison kubeadm | awk '{print $3}' | grep "^$PREV\." | head -1)
apt-mark unhold kubeadm kubelet kubectl
apt-get install -y -qq --allow-downgrades kubeadm="$OLD" kubelet="$OLD" kubectl="$OLD"
apt-mark hold kubeadm kubelet kubectl
systemctl daemon-reload
systemctl restart kubelet

# 3) 문제의 시작 조건: 저장소는 이미 새 마이너를 가리키고 apt update 도 끝난 상태
sed -i -E "s#core:/stable:/v[0-9]+\.[0-9]+/#core:/stable:/v$CUR/#" $LIST
apt-get update -qq

# 4) 시작 상태 확인: 세 패키지 모두 v$PREV, hold 걸림, 저장소는 v$CUR
sleep 10
kubeadm version -o short
kubelet --version
apt-mark showhold
grep -o 'core:/stable:/v[0-9.]*' $LIST
systemctl is-active kubelet
