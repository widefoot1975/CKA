#!/usr/bin/env bash
# a13 — 실습 후 정리 (kubelet 설정 파일을 원본으로 되돌리고 kubelet 을 다시 띄운다)
# 실행: worker01 에서 sudo bash cleanup.sh
#       또는 k8s-c1 에서 ssh worker01 'sudo bash -s' < cleanup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash cleanup.sh"; exit 1; }
CFG=/var/lib/kubelet/config.yaml
KEEP=/root/.cka-setup

# 1) setup.sh 가 보관한 원본으로 되돌린다
if [ -f $KEEP/a13-kubelet-config.yaml ]; then
  cp -p $KEEP/a13-kubelet-config.yaml $CFG
  rm $KEEP/a13-kubelet-config.yaml
fi

# 2) kubelet 을 켜고 부팅 시 자동 시작도 켠 뒤 다시 띄운다
systemctl enable kubelet
systemctl restart kubelet

# 3) kubelet 이 계속 active 인지 확인 (최대 30초)
for _ in $(seq 10); do sleep 3; systemctl is-active --quiet kubelet && break; done
systemctl is-active kubelet
grep clientCAFile $CFG
