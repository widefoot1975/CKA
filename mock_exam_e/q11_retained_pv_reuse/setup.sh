#!/usr/bin/env bash
# e11 — Reattach a retained PV · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (PV 는 클러스터 범위라 따로 지운다)
kubectl delete ns finance --ignore-not-found --wait=true
kubectl delete pv ledger-pv --ignore-not-found --wait=true
rm -rf /opt/course/e11
kubectl create ns finance

# 1) 데이터를 둘 노드 하나 고르기 (워커 우선). hostPath 라서 PV 를 이 노드에 묶어 둔다
NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o name | head -1 | cut -d/ -f2)
NODE=${NODE:-$(kubectl get nodes -o name | head -1 | cut -d/ -f2)}
echo "ledger-pv 노드: $NODE"

# 2) 살아남은 PV ledger-pv (Available) + 그 디렉터리에 예전 데이터를 써 두는 파드 — PV 는 kubectl create 로 못 만들어서 YAML
kubectl apply -f - <<YAML
apiVersion: v1
kind: PersistentVolume
metadata: {name: ledger-pv}
spec:
  capacity: {storage: 250Mi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath: {path: /srv/ledger-pv, type: DirectoryOrCreate}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [$NODE]}
---
apiVersion: v1
kind: Pod
metadata: {name: seed, namespace: finance}
spec:
  nodeName: $NODE
  restartPolicy: Never
  containers:
  - name: seed
    image: busybox:1.36
    command: [sh, -c, "echo 'old ledger data' > /d/boot.log"]
    volumeMounts: [{name: d, mountPath: /d}]
  volumes:
  - name: d
    hostPath: {path: /srv/ledger-pv, type: DirectoryOrCreate}
YAML
kubectl -n finance wait pod seed --for=jsonpath='{.status.phase}'=Succeeded --timeout=120s
kubectl -n finance delete pod seed

# 3) 남아 있는 Deployment 매니페스트 사본 (volumes 가 빠진 상태 — 문제에서 추가한다)
mkdir -p /opt/course/e11
cat > /opt/course/e11/ledger-deploy.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ledger
  namespace: finance
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ledger
  template:
    metadata:
      labels:
        app: ledger
    spec:
      containers:
      - name: ledger
        image: busybox:1.36
        command: ["sh", "-c", "date >> /var/lib/ledger/boot.log; sleep 3600"]
YAML

# 4) 시작 상태 확인: ledger-pv 는 Available, finance 에는 PVC·Deployment 없음
kubectl get pv ledger-pv
kubectl -n finance get pvc,deploy
