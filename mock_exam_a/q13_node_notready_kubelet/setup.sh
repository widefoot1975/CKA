#!/usr/bin/env bash
# a13 — Recover a NotReady node · 사전 환경 설정 (worker01 의 kubelet 설정 파일에 경로 오타를 낸다)
# 실행: worker01 에서 sudo bash setup.sh   (여러 번 실행해도 안전)
#       또는 k8s-c1 에서 ssh worker01 'sudo bash -s' < setup.sh
# 주의: 실행하면 worker01 이 NotReady 가 된다. 실습이 끝나면 꼭 cleanup.sh 를 실행한다.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash setup.sh"; exit 1; }
CFG=/var/lib/kubelet/config.yaml
KEEP=/root/.cka-setup          # 원본 설정 보관 위치

# 0) worker 노드인지 확인 (컨트롤 플레인 노드에서는 하지 않는다)
[ ! -f /etc/kubernetes/manifests/kube-apiserver.yaml ] || { echo "컨트롤 플레인 노드입니다. worker 노드에서 실행하세요."; exit 1; }
[ -f $CFG ] || { echo "$CFG 이 없습니다. kubeadm 으로 join 한 worker 노드에서 실행하세요."; exit 1; }

# 1) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌리고, 없으면 지금 원본을 보관한다
mkdir -p $KEEP
if [ -f $KEEP/a13-kubelet-config.yaml ]; then
  cp -p $KEEP/a13-kubelet-config.yaml $CFG
else
  grep -q 'clientCAFile: /etc/kubernetes/pki/ca.crt$' $CFG || { echo "clientCAFile 줄을 찾지 못했습니다."; exit 1; }
  cp -p $CFG $KEEP/a13-kubelet-config.yaml
fi

# 2) 고장 내기 ("동료의 수정"): client CA 파일 경로 끝에 글자를 하나 붙인다 → kubelet 이 시작하자마자 종료
sed -i 's#clientCAFile: /etc/kubernetes/pki/ca.crt$#clientCAFile: /etc/kubernetes/pki/ca.crtx#' $CFG
systemctl enable kubelet
systemctl restart kubelet || true

# 3) 시작 상태 확인: kubelet 은 activating (auto-restart) 을 반복, containerd 는 active.
#    약 1분 뒤 k8s-c1 에서 worker01 이 NotReady 로 바뀐다
sleep 5
systemctl is-active kubelet || true
systemctl is-active containerd || true
