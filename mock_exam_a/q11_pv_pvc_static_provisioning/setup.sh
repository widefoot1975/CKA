#!/usr/bin/env bash
# a11 — Static PV provisioning · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) worker01 이 있어야 한다 (PV 를 이 노드에 고정하는 문제)
kubectl get node worker01 >/dev/null || { echo "노드 worker01 이 없음 — 노드 이름을 먼저 확인할 것"; exit 1; }

# 1) 이전 실습 흔적 정리 — ops 는 a12 등 다른 문제도 쓰므로 namespace 는 지우지 않고 이 문제의 리소스만 지운다
kubectl create ns ops --dry-run=client -o yaml | kubectl apply -f -
kubectl -n ops delete pod logger --ignore-not-found --wait=true
kubectl -n ops delete pvc pvc-logs pvc-logs-2 --ignore-not-found --wait=true
kubectl delete pv pv-logs --ignore-not-found --wait=true

# 2) worker01 의 /mnt/data/logs 를 지워 1단계부터 다시 할 수 있게 한다 (/mnt/data 의 다른 디렉터리는 건드리지 않음)
kubectl -n default delete pod a11-reset --ignore-not-found --wait=true
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: a11-reset, namespace: default}
spec:
  nodeName: worker01
  restartPolicy: Never
  tolerations: [{operator: Exists}]
  containers:
  - name: reset
    image: busybox:1.36
    command: [sh, -c, "rm -rf /host/logs"]
    volumeMounts: [{name: d, mountPath: /host}]
  volumes:
  - name: d
    hostPath: {path: /mnt/data, type: DirectoryOrCreate}
YAML
kubectl -n default wait pod a11-reset --for=jsonpath='{.status.phase}'=Succeeded --timeout=120s
kubectl -n default delete pod a11-reset

# 3) 시작 상태 확인: pv-logs 없음, ops 에 pvc-logs·logger 없음, StorageClass manual 없음
kubectl get pv pv-logs 2>/dev/null || echo "pv-logs 없음 (정상)"
kubectl -n ops get pod,pvc
kubectl get storageclass
