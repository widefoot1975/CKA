#!/usr/bin/env bash
# c11 — Per-replica storage with volumeClaimTemplates · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) local-path 프로비저너 v0.0.37 설치 (동적 프로비저닝용)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) StorageClass standard — 클러스터에 이미 있으면 그대로 쓰고, 없을 때만 local-path 로 만든다
#    (직접 만든 것에는 레이블을 붙여 cleanup.sh 가 그것만 지우게 한다)
if ! kubectl get sc standard >/dev/null 2>&1; then
  cat <<'YAML' | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  labels:
    cka-practice/created-by: c11
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML
fi

# 3) 이전 실습 흔적 정리 — namespace data 는 C10·D12 도 쓰므로 이 문제의 리소스만 지운다
kubectl create ns data --dry-run=client -o yaml | kubectl apply -f -
kubectl -n data delete sts queue --ignore-not-found --wait=true
kubectl -n data delete svc queue --ignore-not-found
for pvc in $(kubectl -n data get pvc -o name | grep '^persistentvolumeclaim/data-queue-' || true); do
  kubectl -n data delete "$pvc" --wait=true
done

# 4) 시작 상태 확인: StorageClass standard 가 있고, data 에 queue 관련 리소스가 없음
kubectl get sc standard
kubectl -n data get sts,svc,pvc
