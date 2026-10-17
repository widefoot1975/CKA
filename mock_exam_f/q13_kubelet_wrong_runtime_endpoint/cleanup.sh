#!/usr/bin/env bash
# f13 — 실습 후 정리 (worker02 의 kubelet 설정을 setup 이 보관한 원본으로 되돌리고 kubelet 을 재시작한다)
# 실행: bash cleanup.sh   (k8s-c1 에서 실행)
set -euo pipefail

NODE=${NODE:-worker02}
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
for f in /var/lib/kubelet/config.yaml /var/lib/kubelet/kubeadm-flags.env; do
  if [ -f "$f.f13.orig" ]; then cp -p "$f.f13.orig" "$f"; rm -f "$f.f13.orig"; fi
done
rm -rf /opt/course/f13
systemctl restart kubelet
REMOTE
kubectl wait node "$NODE" --for=condition=Ready --timeout=120s
