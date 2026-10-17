#!/usr/bin/env bash
# f11 — Protect a dynamically provisioned volume · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) local-path 프로비저너 v0.0.37 설치 (StorageClass local-path, reclaimPolicy Delete, WaitForFirstConsumer)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리: 지난번에 Retain 으로 바꾼 PV 가 있으면 Delete 로 되돌린 뒤 지운다
#    (Retain 인 채로 PVC 를 지우면 PV 와 노드의 데이터 디렉터리가 Released 로 남는다)
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="db")]}{.metadata.name}{"\n"}{end}'); do
  kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
done
kubectl delete ns db --ignore-not-found --wait=true
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="db")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete pv "$pv" --ignore-not-found --wait=true
done
rm -rf /opt/course/f11
kubectl create ns db

# 3) PVC pg-data 와 그것을 쓰는 파드 pg (WaitForFirstConsumer 라서 파드가 떠야 PV 가 만들어지고 Bound 된다)
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: pg-data, namespace: db}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: local-path
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: pg, namespace: db, labels: {app: pg}}
spec:
  containers:
  - name: pg
    image: busybox:1.36
    command: [sh, -c, "date > /var/lib/pg/created.txt; sleep 36000"]
    volumeMounts: [{name: data, mountPath: /var/lib/pg}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: pg-data}
YAML
kubectl -n db wait pod pg --for=condition=Ready --timeout=180s
kubectl -n db wait pvc pg-data --for=jsonpath='{.status.phase}'=Bound --timeout=60s

# 4) 시작 상태 확인: pg-data 는 Bound, 그 PV 의 RECLAIM POLICY 는 Delete
kubectl -n db get pvc pg-data
kubectl get pv
