# q12 — Inspect CSI drivers and use a block volumeMode

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 Block 모드를 지원하는 스토리지가 있어야 3~5번을 풀 수 있다. 실습 클러스터에는 보통 그런 CSI 드라이버가
없으므로, `worker01` 에 2Gi 짜리 loop 블록 디바이스를 만들고 그것을 가리키는 Block 모드 PV 와 StorageClass
`csi-block` 을 미리 만들어 둔다. CSI 드라이버가 하나도 등록되어 있지 않으면 1번 답이 빈 파일이 되지 않도록 연습용
CSIDriver 등록 오브젝트도 하나 만든다.
`k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다(`k8s-c1` 에서 `ssh worker01` 이 되어야 한다). 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 노드 worker01 이 있는지 확인
kubectl get node worker01

# 1) 이전 실습 흔적 정리 — namespace raw(파드·PVC), 연습용 PV, 답 파일 디렉터리
kubectl delete ns raw --ignore-not-found --wait=true
kubectl delete pv -l practice=b12 --ignore-not-found --wait=true
sudo rm -rf /opt/q12
sudo mkdir -p /opt/q12 && sudo chown $(id -u):$(id -g) /opt/q12

# 2) CSI 드라이버가 하나도 없을 때만 — 연습용 CSIDriver 등록 오브젝트 (kubectl create 로는 못 만들어서 YAML)
kubectl get csidrivers
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

# 3) worker01 에 2Gi 파일을 만들고 loop 블록 디바이스로 붙인다 (이미 붙어 있으면 그대로 쓴다)
LOOP=$(ssh worker01 'sudo bash -s' <<'EOS'
set -e
mkdir -p /var/lib/b12
[ -f /var/lib/b12/disk.img ] || truncate -s 2G /var/lib/b12/disk.img
DEV=$(losetup -j /var/lib/b12/disk.img | cut -d: -f1 | head -n1)
[ -n "$DEV" ] || DEV=$(losetup --find --show /var/lib/b12/disk.img)
echo "$DEV"
EOS
)
echo "$LOOP"     # 예: /dev/loop0

# 4) StorageClass csi-block 이 없을 때만 — 연습용(정적 프로비저닝, WaitForFirstConsumer)
kubectl get sc csi-block
kubectl apply -f - <<'YAML'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-block
  labels: {practice: b12}
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
YAML

# 5) 4번에서 연습용 StorageClass 를 만들었을 때만 — loop 디바이스를 가리키는 Block 모드 PV
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

# 6) namespace raw (비어 있다)
kubectl create ns raw

# 7) 시작 상태 확인
kubectl get csidrivers
kubectl get csinodes
kubectl get sc csi-block
kubectl get pv -l practice=b12
kubectl -n raw get pvc,pod
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/q12` 는 비어 있고, `kubectl get csidrivers` 에 드라이버가 한 개 이상 보이며, `raw` 에는 PVC 도
파드도 없다. 연습용 StorageClass 를 만든 경우 PV `b12-block-pv`(2Gi, `Block`, `Available`)가 하나 있다.
StorageClass 가 `WaitForFirstConsumer` 라서 PVC 를 만들어도 파드가 생길 때까지 `Pending` 인 것이 정상이고,
파드는 PV 의 nodeAffinity 때문에 `worker01` 에 뜬다. 스크립트는 이미 드라이버나 `csi-block` 이 있으면 새로 만들지
않고 있는 것을 쓴다.
연습용 `hostpath.csi.k8s.io` 는 **등록 정보(CSIDriver 오브젝트)만** 있고 드라이버 파드가 없으므로 `csinodes` 의
`drivers` 는 비어 있다. 그때 2번 답은 노드 이름과 빈 node ID(`<none>`)가 된다. 연습용 `csi-block` 은 CSI 가 아니라
`local` PV 로 Block 디바이스를 흉내 낸 것이지만, PVC·파드 쪽 작성법(3~5번)은 CSI 드라이버를 쓸 때와 똑같다.
loop 디바이스는 `worker01` 을 재부팅하면 풀리므로 재부팅 뒤에는 setup 을 다시 실행한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns raw --ignore-not-found --wait=true
kubectl delete pv -l practice=b12 --ignore-not-found --wait=true
kubectl delete sc -l practice=b12 --ignore-not-found
kubectl delete csidriver -l practice=b12 --ignore-not-found
ssh worker01 'sudo bash -s' <<'EOS'
if [ -f /var/lib/b12/disk.img ]; then
  for DEV in $(losetup -j /var/lib/b12/disk.img | cut -d: -f1); do losetup -d "$DEV"; done
fi
rm -rf /var/lib/b12
EOS
sudo rm -rf /opt/q12
```

</details>

## Task

A database is being migrated to raw block storage.

1. List the CSI drivers registered in the cluster. For each, write its name and whether
   it requires attach (`spec.attachRequired`) to `/opt/q12/drivers.txt`.
2. Write to `/opt/q12/csinodes.txt` each node's name together with the driver-specific
   node ID the CSI driver registered for it.
3. In namespace `raw`, create PVC `block-pvc`: `2Gi`, `ReadWriteOnce`, StorageClass
   `csi-block`, `volumeMode: Block`.
4. Create pod `block-user` (`busybox:1.36`, kept alive) that consumes `block-pvc` as a
   raw device at `/dev/xvdb`. Do **not** mount a filesystem.
5. From inside the pod, prove `/dev/xvdb` is a block device and write the proof to
   `/opt/q12/proof.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
