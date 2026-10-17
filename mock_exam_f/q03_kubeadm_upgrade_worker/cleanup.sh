#!/usr/bin/env bash
# f03 — 실습 후 정리. 문제를 끝까지 풀었다면 할 일이 없다.
# 중간에 그만뒀을 때만, worker01 을 컨트롤 플레인과 같은 버전으로 되돌리고 uncordon 한다.
# 실행: sudo bash cleanup.sh   (worker01 에서 root 로 실행)
set -euo pipefail
LIST=/etc/apt/sources.list.d/kubernetes.list
KC="kubectl --kubeconfig /etc/kubernetes/kubelet.conf"

CP=$($KC get --raw /version | grep -o '"gitVersion": *"v[0-9.]*' | grep -o '[0-9][0-9.]*')
CUR=$(echo "$CP" | cut -d. -f1,2)
sed -i -E "s#core:/stable:/v[0-9]+\.[0-9]+/#core:/stable:/v$CUR/#" $LIST
apt-get update -qq
NEW=$(apt-cache madison kubeadm | awk '{print $3}' | grep "^$CP-" | head -1)
apt-mark unhold kubeadm kubelet kubectl
apt-get install -y -qq --allow-downgrades kubeadm="$NEW" kubelet="$NEW" kubectl="$NEW"
apt-mark hold kubeadm kubelet kubectl
kubeadm upgrade node
systemctl daemon-reload
systemctl restart kubelet
kubelet --version
echo "drain 한 채 그만뒀다면 k8s-c2 에서: kubectl uncordon worker01"
