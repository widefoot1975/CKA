#!/usr/bin/env bash
# c16 — Pods evicted under node disk pressure · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 필요: k8s-c1 → worker02 로 ssh 가 되고, worker02 에서 sudo 를 암호 없이 쓸 수 있어야 한다.
# 주의: 실행하면 worker02 에 큰 파일이 생기고 DiskPressure 가 걸려 worker02 의 일반 파드가 축출된다.
#       실습이 끝나면 꼭 cleanup.sh 를 실행한다 (공간과 kubelet 설정을 되돌린다).
set -euo pipefail

NODE=${NODE:-worker02}
NS=diskload
kubectl get node "$NODE" >/dev/null
ssh "$NODE" true

# 0) 이전 실습 흔적 정리: 원본 kubelet 설정 복구, 채운 파일 삭제, namespace 삭제
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
CFG=/var/lib/kubelet/config.yaml
rm -rf /var/lib/c16-dump
if [ -f "$CFG.c16.orig" ]; then cp -p "$CFG.c16.orig" "$CFG"; systemctl restart kubelet; fi
REMOTE
kubectl delete ns "$NS" --ignore-not-found --wait=true
kubectl wait node "$NODE" --for=condition=Ready --timeout=120s
kubectl wait node "$NODE" --for=condition=DiskPressure=false --timeout=360s   # 재실행이면 최대 5분

# 1) worker02 에 고정된 Deployment — 축출될 파드들
kubectl create ns "$NS"
cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: report-gen
  namespace: $NS
spec:
  replicas: 3
  selector:
    matchLabels:
      app: report-gen
  template:
    metadata:
      labels:
        app: report-gen
    spec:
      nodeSelector:
        kubernetes.io/hostname: $NODE
      containers:
      - name: gen
        image: busybox:1.36
        command: ["sh", "-c", "while true; do date; sleep 30; done"]
YAML
kubectl -n "$NS" rollout status deploy report-gen --timeout=180s

# 2) worker02 에서: 원본 설정을 보관하고, 큰 파일로 디스크를 채운 뒤
#    "채운 파일을 지우면 풀리는" 지점에 nodefs.available 임계값을 둔다
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
CFG=/var/lib/kubelet/config.yaml
[ -f "$CFG.c16.orig" ] || cp -p "$CFG" "$CFG.c16.orig"

# kubelet 의 nodefs(/var/lib/kubelet)와 같은 파일시스템에 채워야 시그널이 움직인다
mkdir -p /var/lib/c16-dump
if [ "$(stat -c %d /var/lib/c16-dump)" != "$(stat -c %d /var/lib/kubelet)" ]; then
  echo "/var/lib/c16-dump 와 /var/lib/kubelet 이 다른 파일시스템입니다. 중단합니다."; rm -rf /var/lib/c16-dump; exit 1
fi

AVAIL=$(df -BM --output=avail /var/lib/kubelet | tail -1 | tr -dc '0-9')   # 지금 남은 공간(MiB)
[ "$AVAIL" -ge 1024 ] || { echo "남은 공간이 1GiB 미만이라 실습을 만들지 않습니다."; rm -rf /var/lib/c16-dump; exit 1; }
FILL=$(( AVAIL * 40 / 100 )); [ "$FILL" -le 2048 ] || FILL=2048           # 남은 공간의 40%, 최대 2GiB
THRESH=$(( AVAIL - FILL / 2 ))                                               # 채운 뒤 < THRESH < 지운 뒤

fallocate -l "${FILL}M" /var/lib/c16-dump/core.img 2>/dev/null \
  || dd if=/dev/zero of=/var/lib/c16-dump/core.img bs=1M count="$FILL" status=none
sync

# evictionHard 는 일부만 적으면 나머지 시그널이 0 이 되므로 기본값을 모두 같이 적는다
awk '/^evictionHard:/{skip=1; next} skip && /^[[:space:]]/{next} {skip=0; print}' \
  "$CFG.c16.orig" > "$CFG"
cat >> "$CFG" <<CONF
evictionHard:
  memory.available: "100Mi"
  nodefs.available: "${THRESH}Mi"
  nodefs.inodesFree: "5%"
  imagefs.available: "15%"
  imagefs.inodesFree: "5%"
CONF
systemctl restart kubelet
REMOTE

# 3) 시작 상태 확인: DiskPressure=True 가 되고 파드가 축출될 때까지 최대 3분 기다린다
for i in $(seq 1 36); do
  dp=$(kubectl get node "$NODE" -o jsonpath='{.status.conditions[?(@.type=="DiskPressure")].status}')
  ev=$(kubectl -n "$NS" get pods --field-selector=status.phase=Failed --no-headers 2>/dev/null | wc -l)
  [ "$dp" = "True" ] && [ "$ev" -gt 0 ] && break
  sleep 5
done
kubectl get node "$NODE"
kubectl -n "$NS" get pods -o wide
