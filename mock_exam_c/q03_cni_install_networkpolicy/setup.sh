#!/usr/bin/env bash
# c03 — Install a CNI plugin that enforces NetworkPolicy · 사전 환경 설정
# CNI 는 한 번 깔면 되돌리기 어렵다. 이 스크립트는 클러스터를 바꾸지 않는다 — 기존 CNI 를 지우지 않고,
# 매니페스트 두 벌을 /opt/course/q03 에 받아 두고, 이 클러스터에서 문제를 그대로 풀 수 있는지(CNI 없음) 점검한다.
# 실행: bash setup.sh   (k8s-c4 에서 실행, 여러 번 실행해도 안전 — /opt/course 에 쓸 권한 필요)
set -euo pipefail
CALICO=v3.30.3
FLANNEL=v0.27.4

# 0) 이전 실습 흔적 정리 (cni-test 는 이 문제만 쓴다)
kubectl delete ns cni-test --ignore-not-found --wait=true
rm -rf /opt/course/q03

# 1) 매니페스트 두 벌 받아 두기 — Calico 는 operator 방식, custom-resources.yaml 의 CIDR 은 기본값(192.168.0.0/16) 그대로
mkdir -p /opt/course/q03/flannel /opt/course/q03/calico
curl -fsSL -o /opt/course/q03/flannel/kube-flannel.yml \
  https://github.com/flannel-io/flannel/releases/download/$FLANNEL/kube-flannel.yml
for f in operator-crds.yaml tigera-operator.yaml custom-resources.yaml; do
  curl -fsSL -o /opt/course/q03/calico/$f \
    https://raw.githubusercontent.com/projectcalico/calico/$CALICO/manifests/$f
done
ls -R /opt/course/q03

# 2) 이미 CNI 가 깔려 있는지 — 있으면 2·3번은 그대로 재현되지 않는다 (스크립트는 지우지 않는다)
CNI=$(kubectl get ds -A --no-headers 2>/dev/null \
  | grep -Eo 'calico-node|kube-flannel-ds|cilium|weave-net|kube-router|antrea-agent' | sort -u | tr '\n' ' ' || true)
if [ -z "$CNI" ]; then
  echo "OK: CNI 가 없습니다. 노드가 NotReady 인 문제 상태 그대로입니다"
else
  echo "NG: 이미 CNI 가 있습니다 ($CNI). 2·3번은 CNI 없이 새로 만든 kubeadm 클러스터에서 풀어야 합니다"
fi

# 3) kubeadm 에 podSubnet 이 지정되어 있는지 (값은 1번의 답이라 출력하지 않는다)
if kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep -q podSubnet; then
  echo "OK: kubeadm-config 에 podSubnet 이 있습니다"
else
  echo "NG: podSubnet 이 없습니다. kubeadm init --pod-network-cidr=<대역> 으로 만든 클러스터가 필요합니다"
fi

# 4) 4번용 노드 수 (서로 다른 노드 두 개)와 시작 상태
kubectl get nodes
kubectl -n kube-system get pods -l k8s-app=kube-dns -o wide
