#!/usr/bin/env bash
# b12 — Inspect CSI drivers and use a block volumeMode · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전. worker01 에는 ssh 로 접속한다)
set -euo pipefail

# 0) 노드 worker01 이 있는지 확인
kubectl get node worker01

# 1) 이전 실습 흔적 정리 — namespace raw(파드·PVC), 연습용 PV, 답 파일 디렉터리
kubectl delete ns raw --ignore-not-found --wait=true
kubectl delete pv -l practice=b12 --ignore-not-found --wait=true
sudo rm -rf /opt/q12
sudo mkdir -p /opt/q12
sudo chown "$(id -u):$(id -g)" /opt/q12

# 2) CSI 드라이버가 하나도 없으면 1번 답이 빈 파일이 되므로, 연습용 CSIDriver 등록 오브젝트를 하나 만든다
#    (실제 드라이버는 없고 등록 정보만 있다 — 라벨 practice=b12 로 표시해 정리 때 이것만 지운다)
if [ -z "$(kubectl get csidrivers -o name)" ]; then
  kubectl apply -f - <<'YAML'
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: hostpath.csi.k8s.io
  labels: {practice: b12}
spec:
  attachRequired: false
  podInfoOnMount: true
  volumeLifecycleModes: [Persistent]
YAML
fi

# 3) worker01 에 2Gi 짜리 파일을 만들고 loop 블록 디바이스로 붙인다 (이미 붙어 있으면 그대로 쓴다)
LOOP=$(ssh worker01 'sudo bash -s' <<'EOS'
set -euo pipefail
mkdir -p /var/lib/b12
[ -f /var/lib/b12/disk.img ] || truncate -s 2G /var/lib/b12/disk.img
DEV=$(losetup -j /var/lib/b12/disk.img | cut -d: -f1 | head -n1)
[ -n "$DEV" ] || DEV=$(losetup --find --show /var/lib/b12/disk.img)
echo "$DEV"
EOS
)
echo "worker01 의 블록 디바이스: $LOOP"

# 4) StorageClass csi-block — 이미 있으면 그것을 쓰고, 없을 때만 연습용(정적 프로비저닝)으로 만든다
if ! kubectl get sc csi-block >/dev/null 2>&1; then
  kubectl apply -f - <<'YAML'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-block
  labels: {practice: b12}
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
YAML
fi

# 5) 연습용 StorageClass 일 때만, 위 loop 디바이스를 가리키는 Block 모드 PV 를 미리 만들어 둔다
if [ "$(kubectl get sc csi-block -o jsonpath='{.metadata.labels.practice}')" = "b12" ]; then
  kubectl apply -f - <<YAML
apiVersion: v1
kind: PersistentVolume
metadata:
  name: b12-block-pv
  labels: {practice: b12}
spec:
  capacity: {storage: 2Gi}
  volumeMode: Block
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: csi-block
  local:
    path: ${LOOP}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [worker01]}
YAML
fi

# 6) namespace raw (비어 있다. PVC 와 파드는 문제에서 직접 만든다)
kubectl create ns raw

# 7) 시작 상태 확인
kubectl get csidrivers
kubectl get csinodes
kubectl get sc csi-block
kubectl get pv -l practice=b12
kubectl -n raw get pvc,pod
