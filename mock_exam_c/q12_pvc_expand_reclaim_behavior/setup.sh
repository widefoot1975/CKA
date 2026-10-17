#!/usr/bin/env bash
# c12 — Expand a PVC and observe reclaim behaviour · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) local-path 프로비저너 v0.0.37 설치 (provisioner rancher.io/local-path)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deploy local-path-provisioner --timeout=180s

# 2) 이전 실습 흔적 정리
#    slow-retain PV 는 Retain 이라 PVC 를 지워도 남는다 → Delete 로 되돌린 뒤 namespace 를 지우고 남은 PV 를 지운다
#    (5번에서 claimRef 를 지운 PV 는 namespace 정보가 없으므로 클래스 이름으로 찾는다)
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="slow-retain")]}{.metadata.name}{"\n"}{end}'); do
  kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
done
kubectl delete ns files --ignore-not-found --wait=true
for pv in $(kubectl get pv -o jsonpath='{range .items[?(@.spec.storageClassName=="slow-retain")]}{.metadata.name}{"\n"}{end}{range .items[?(@.spec.claimRef.namespace=="files")]}{.metadata.name}{"\n"}{end}'); do
  # Released 는 프로비저너가 디렉터리째 지우도록 잠시 기다리고, Available(5번에서 claimRef 를 지운 것)은 바로 지운다
  if [ "$(kubectl get pv "$pv" -o jsonpath='{.status.phase}' 2>/dev/null)" = "Released" ]; then
    kubectl wait --for=delete "pv/$pv" --timeout=60s || true
  fi
  kubectl delete pv "$pv" --ignore-not-found --wait=true
done
kubectl delete sc slow slow-retain --ignore-not-found

# 3) StorageClass slow — 확장을 허용하지 않는 상태로 시작 (allowVolumeExpansion 없음)
#    apply 대신 create 로 만들어 last-applied 어노테이션이 붙지 않게 한다 (4번에서 yaml 을 복사하기 쉽게)
kubectl create -f - <<'YAML'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML

# 4) namespace files, PVC archive (1Gi, slow) 와 그것을 /data 에 마운트한 파드 writer
#    WaitForFirstConsumer 라서 파드가 떠야 PV 가 만들어지고 Bound 된다
kubectl create ns files
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive, namespace: files}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: slow
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: writer, namespace: files}
spec:
  containers:
  - name: writer
    image: busybox:1.36
    command: [sh, -c, "date > /data/started.txt; sleep 86400"]
    volumeMounts: [{name: data, mountPath: /data}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: archive}
YAML
kubectl -n files wait pod writer --for=condition=Ready --timeout=180s
kubectl -n files wait pvc archive --for=jsonpath='{.status.phase}'=Bound --timeout=60s

# 5) 시작 상태 확인: slow 의 ALLOWVOLUMEEXPANSION 은 false, archive 는 1Gi Bound, writer 는 Running
kubectl get sc slow
kubectl -n files get pvc,pod
