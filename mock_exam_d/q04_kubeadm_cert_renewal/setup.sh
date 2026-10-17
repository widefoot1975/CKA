#!/usr/bin/env bash
# d04 — Check and renew a control plane certificate · 사전 환경 설정
# 실행: sudo bash setup.sh   (cp01 에서 root 로 실행, 여러 번 실행해도 안전)
set -euo pipefail
MAN=/etc/kubernetes/manifests

# 0) kubeadm 으로 만든 컨트롤 플레인 노드인지 확인
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }
command -v kubeadm >/dev/null || { echo "kubeadm 이 없습니다. 컨트롤 플레인 노드(cp01)에서 실행하세요"; exit 1; }

# 1) 지난 실습에서 매니페스트를 밖으로 옮겨 둔 채 끝났으면 되돌린다
if [ ! -f $MAN/kube-apiserver.yaml ] && [ -f /root/kube-apiserver.yaml ]; then
  mv /root/kube-apiserver.yaml $MAN/
  echo "kube-apiserver.yaml 을 $MAN 으로 되돌렸습니다"
fi
[ -f $MAN/kube-apiserver.yaml ] || { echo "$MAN/kube-apiserver.yaml 이 없습니다"; exit 1; }

# 2) 이전 실습 흔적 정리 — 답 파일 디렉터리를 비워서 새로 만든다
rm -rf /opt/course/d04
mkdir -p /opt/course/d04

# 3) 시작 상태 확인: 매니페스트 디렉터리에는 yaml 4개만, apiserver 인증서의 현재 만료일
ls $MAN
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate
kubeadm certs check-expiration | grep -E '^(CERTIFICATE|admin.conf|apiserver) '
