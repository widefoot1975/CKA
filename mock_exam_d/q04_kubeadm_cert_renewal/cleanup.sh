#!/usr/bin/env bash
# d04 — 실습 후 정리 (갱신한 인증서는 되돌릴 필요가 없다. 답 파일만 지운다)
# 실행: sudo bash cleanup.sh   (cp01 에서 root 로 실행)
set -euo pipefail
MAN=/etc/kubernetes/manifests

# kube-apiserver 매니페스트를 밖에 둔 채 끝났으면 되돌린다 (그대로 두면 API 서버가 꺼진 상태로 남는다)
if [ ! -f $MAN/kube-apiserver.yaml ] && [ -f /root/kube-apiserver.yaml ]; then
  mv /root/kube-apiserver.yaml $MAN/
fi
rm -rf /opt/course/d04
