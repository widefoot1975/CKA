#!/usr/bin/env bash
# f13 — Node NotReady after a kubelet config change · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 필요: k8s-c1 → worker02 로 ssh 가 되고, worker02 에서 sudo 를 암호 없이 쓸 수 있어야 한다.
# 주의: 실행하면 worker02 가 NotReady 가 된다. 실습이 끝나면 꼭 cleanup.sh 를 실행한다.
set -euo pipefail

NODE=${NODE:-worker02}
kubectl get node "$NODE" >/dev/null
ssh "$NODE" true

# 0~1) worker02 에서: 처음 실행할 때 원본 설정을 보관하고, 그다음부터는 원본으로 되돌린 뒤 장애를 만든다
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
CFG=/var/lib/kubelet/config.yaml
FLAGS=/var/lib/kubelet/kubeadm-flags.env
for f in "$CFG" "$FLAGS"; do
  [ -f "$f" ] || continue
  if [ -f "$f.f13.orig" ]; then cp -p "$f.f13.orig" "$f"; else cp -p "$f" "$f.f13.orig"; fi
done
rm -rf /opt/course/f13

# 런타임 엔드포인트를 플래그로 주고 있으면 플래그가 config.yaml 보다 우선하므로 플래그를 뺀다
if [ -f "$FLAGS" ]; then
  sed -i -E 's#--container-runtime-endpoint=[^ "]+ ?##' "$FLAGS"
fi
if grep -q '^containerRuntimeEndpoint:' "$CFG"; then
  sed -i -E 's#^containerRuntimeEndpoint:.*#containerRuntimeEndpoint: unix:///run/containerd/containerd.sok#' "$CFG"
else
  echo 'containerRuntimeEndpoint: unix:///run/containerd/containerd.sok' >> "$CFG"
fi
systemctl restart kubelet || true
REMOTE

# 2) 시작 상태 확인: 노드가 NotReady(Ready=Unknown/False) 가 될 때까지 최대 2분 기다린다
for i in $(seq 1 24); do
  st=$(kubectl get node "$NODE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
  [ "$st" != "True" ] && break
  sleep 5
done
kubectl get nodes
