#!/usr/bin/env bash
# c16 — 실습 후 정리 (채운 파일을 지워 공간을 돌려주고, kubelet 설정을 setup 이 보관한 원본으로 되돌린다)
# 실행: bash cleanup.sh   (k8s-c1 에서 실행)
set -euo pipefail

NODE=${NODE:-worker02}
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
CFG=/var/lib/kubelet/config.yaml
rm -rf /var/lib/c16-dump
if [ -f "$CFG.c16.orig" ]; then cp -p "$CFG.c16.orig" "$CFG"; rm -f "$CFG.c16.orig"; fi
systemctl restart kubelet
df -h /var/lib/kubelet
REMOTE
kubectl delete ns diskload --ignore-not-found
kubectl wait node "$NODE" --for=condition=Ready --timeout=120s
# DiskPressure 는 kubelet 재시작 직후 False 로 돌아온다 (최대 5분 걸릴 수 있다)
kubectl wait node "$NODE" --for=condition=DiskPressure=false --timeout=360s
# 이 실습 때문에 다른 namespace 에서 축출된 파드가 있으면 보여 준다 (지우지는 않는다)
kubectl get pods -A --field-selector=status.phase=Failed -o wide | grep -E "NAME|Evicted" || true
