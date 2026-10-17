#!/usr/bin/env bash
# a12 — 실습 후 정리 (namespace ops 는 A11 도 쓰므로 남기고, 이 문제가 만든 파드·PVC·PV 와 worker01 의 디렉터리만 지운다)
# 실행: bash cleanup.sh   (k8s-c1 에서 실행)
set -euo pipefail

NODE=${NODE:-worker01}
if kubectl get ns ops >/dev/null 2>&1; then
  kubectl -n ops delete pod writer reader --ignore-not-found --wait=true
  kubectl -n ops delete pvc pvc-a pvc-b pvc-d pvc-rwx --ignore-not-found --wait=true
fi
kubectl delete pv pv-retain pv-delete --ignore-not-found --wait=true
ssh "$NODE" sudo rm -rf /mnt/data/retain /mnt/data/delete
