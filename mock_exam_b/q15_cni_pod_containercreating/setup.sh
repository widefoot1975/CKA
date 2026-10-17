#!/usr/bin/env bash
# b15 — Pods stuck in ContainerCreating after a CNI failure · 사전 환경 설정 (worker01 의 CNI 플러그인 바이너리를 일부러 치운다)
# 실행: k8s-c1 에서 bash setup.sh   (여러 번 실행해도 안전)
#       kubectl 이 되고 ssh worker01 + sudo 가 되는 곳이어야 한다. 노드 이름이 다르면 NODE=<노드> bash setup.sh
set -euo pipefail
NODE=${NODE:-worker01}
kubectl get node "$NODE" >/dev/null || { echo "노드 $NODE 가 없습니다. NODE=<worker 이름> bash setup.sh 로 실행하세요."; exit 1; }

# 0) 이전 실습 흔적 정리 — CNI 가 정상일 때 지워야 파드 정리가 멈추지 않으므로 노드부터 되돌린다
ssh "$NODE" 'sudo bash -s' <<'EOF'
set -euo pipefail
KEEP=/root/.cka-setup/b15
if [ -f $KEEP/plugin ] && [ -f $KEEP/bin/"$(cat $KEEP/plugin)" ]; then
  P=$(cat $KEEP/plugin)
  [ -e /opt/cni/bin/$P ] || mv $KEEP/bin/$P /opt/cni/bin/$P
fi
rm -rf $KEEP /opt/q15
EOF
kubectl get ns apps >/dev/null 2>&1 || { kubectl create ns apps; kubectl label ns apps cka-setup=b15; }
kubectl -n apps delete deploy web --ignore-not-found --cascade=foreground --wait=true

# 1) 고장 내기: worker01 의 CNI 설정(/etc/cni/net.d)은 그대로 두고, 그 설정이 부르는 플러그인 바이너리만 밖으로 옮긴다
#    (설정이 있으니 노드는 Ready, sandbox 를 만들 때만 실패한다)
ssh "$NODE" 'sudo bash -s' <<'EOF'
set -euo pipefail
[ ! -f /etc/kubernetes/manifests/kube-apiserver.yaml ] || { echo "컨트롤 플레인 노드입니다. worker 노드를 NODE 로 지정하세요."; exit 1; }
KEEP=/root/.cka-setup/b15
CONF=$(ls /etc/cni/net.d/*.conflist /etc/cni/net.d/*.conf 2>/dev/null | sort | head -1 || true)
[ -n "$CONF" ] || { echo "/etc/cni/net.d 에 CNI 설정이 없습니다. CNI 를 먼저 설치하세요."; exit 1; }
P=$(grep -o '"type": *"[^"]*"' "$CONF" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
[ -x /opt/cni/bin/$P ] || { echo "/opt/cni/bin/$P 가 없습니다 ($CONF 의 첫 플러그인)."; exit 1; }
mkdir -p $KEEP/bin /opt/q15
echo "$P" > $KEEP/plugin
mv /opt/cni/bin/$P $KEEP/bin/$P
echo "$(hostname): $CONF 는 그대로, /opt/cni/bin/$P 를 $KEEP/bin/ 으로 옮김"
EOF

# 2) 문제의 Deployment: 4 replica 를 worker 노드에 고르게 나눈다 (worker 2대면 2개씩)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: apps
  labels: {app: web, cka-setup: b15}
spec:
  replicas: 4
  selector:
    matchLabels: {app: web}
  template:
    metadata:
      labels: {app: web}
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        nodeTaintsPolicy: Honor          # taint 가 있는 컨트롤 플레인 노드는 계산에서 뺀다
        labelSelector:
          matchLabels: {app: web}
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
EOF

# 3) 시작 상태 확인: NODE 쪽 파드만 ContainerCreating 이고 IP 가 없다. 노드는 계속 Ready
sleep 30
kubectl get nodes
kubectl -n apps get pods -l app=web -o wide
