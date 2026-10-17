#!/usr/bin/env bash
# b15 — 실습 후 정리 (worker01 의 CNI 플러그인 바이너리를 되돌리고 apps/web 을 지운다)
# 실행: k8s-c1 에서 bash cleanup.sh   (노드 이름이 다르면 NODE=<노드> bash cleanup.sh)
set -euo pipefail
NODE=${NODE:-worker01}

# 1) 보관해 둔 플러그인 바이너리를 되돌린다 (이미 고쳤으면 그대로 둔다). 먼저 해야 파드 삭제가 멈추지 않는다
P=$(ssh "$NODE" 'sudo bash -s' <<'EOF'
set -euo pipefail
KEEP=/root/.cka-setup/b15
P=$(cat $KEEP/plugin 2>/dev/null || true)
if [ -n "$P" ] && [ ! -e /opt/cni/bin/$P ] && [ -f $KEEP/bin/$P ]; then
  mv $KEEP/bin/$P /opt/cni/bin/$P
fi
if [ -n "$P" ] && [ ! -x /opt/cni/bin/$P ]; then echo "$P"; fi   # 그래도 없으면 이름만 알린다
[ -n "$P" ] && [ ! -x /opt/cni/bin/$P ] || rm -rf $KEEP
rm -rf /opt/q15
EOF
)

# 2) 보관본도 없으면 그 노드의 CNI DaemonSet 파드를 다시 띄워 init container 가 바이너리를 다시 깔게 한다
if [ -n "$P" ]; then
  echo "/opt/cni/bin/$P 를 되돌리지 못해 $NODE 의 CNI 파드를 재시작합니다"
  for l in k8s-app=calico-node app=flannel k8s-app=cilium; do
    kubectl delete pod -A -l $l --field-selector spec.nodeName=$NODE --ignore-not-found
  done
  sleep 30
  ssh "$NODE" "sudo bash -c 'test -x /opt/cni/bin/$P && rm -rf /root/.cka-setup/b15'" || \
    echo "아직 /opt/cni/bin/$P 가 없습니다. $NODE 의 CNI 파드 상태를 확인하세요."
fi

# 3) 이 문제가 만든 것만 지운다 (apps 는 A05·D02 도 쓰므로 namespace 는 이 setup 이 만들었고 비었을 때만 지운다)
kubectl -n apps delete deploy -l cka-setup=b15 --ignore-not-found --cascade=foreground --wait=true
if [ "$(kubectl get ns apps -o jsonpath='{.metadata.labels.cka-setup}' 2>/dev/null)" = b15 ] && \
   ! kubectl -n apps get deploy,sts,ds,job,pod --no-headers 2>/dev/null | grep -q .; then
  kubectl delete ns apps
fi

ssh "$NODE" 'ls /opt/cni/bin/'
kubectl -n apps get pods 2>/dev/null || true
