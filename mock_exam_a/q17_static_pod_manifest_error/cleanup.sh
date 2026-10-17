#!/usr/bin/env bash
# a17 — 실습 후 정리 (kube-apiserver 매니페스트를 원본으로 되돌린다)
# 실행: cp01 에서 sudo bash cleanup.sh
#       또는 k8s-c1 에서 ssh cp01 'sudo bash -s' < cleanup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash cleanup.sh"; exit 1; }
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup
mkdir -p $KEEP

# 1) setup.sh 가 보관한 원본으로 되돌린다
if [ -f $KEEP/kube-apiserver.yaml ]; then
  cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml
  rm $KEEP/kube-apiserver.yaml
fi

# 2) 매니페스트 디렉터리 안에 남은 백업(.bak 등)은 kubelet 이 파드로 읽으므로 밖으로 옮긴다
for f in $MAN/*kube-apiserver*; do
  [ "$f" = $MAN/kube-apiserver.yaml ] || mv -v "$f" $KEEP/
done

# 3) API 서버가 다시 응답할 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do kubectl get --raw /healthz >/dev/null 2>&1 && break; sleep 3; done
kubectl get --raw /healthz; echo
kubectl get nodes
