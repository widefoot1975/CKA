# q12 — Inspect CSI drivers and use a block volumeMode · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

데이터베이스를 raw block 스토리지로 이전하는 중이다.

1. 클러스터에 등록된 CSI 드라이버를 나열한다. 각각의 이름과 attach 필요 여부
   (`spec.attachRequired`)를 `/opt/q12/drivers.txt` 에 적는다.
2. 각 노드 이름과 CSI 드라이버가 그 노드에 등록한 드라이버 고유 node ID를
   `/opt/q12/csinodes.txt` 에 적는다.
3. `raw` 네임스페이스에 PVC `block-pvc` 를 만든다. `2Gi`, `ReadWriteOnce`, StorageClass
   `csi-block`, `volumeMode: Block`.
4. `block-pvc` 를 `/dev/xvdb` 의 raw device로 쓰는 파드 `block-user`(`busybox:1.36`, 계속
   살아 있게)를 만든다. 파일시스템을 마운트하지 **않는다**.
5. 파드 안에서 `/dev/xvdb` 가 block device임을 증명하고 그 결과를 `/opt/q12/proof.txt` 에 적는다.

## 모범 풀이

**1~2) 드라이버와 노드 등록 정보.** `csidrivers` 는 클러스터 범위, `csinodes` 는 노드별
등록 상태입니다.

```bash
kubectl get csidrivers -o custom-columns=\
'NAME:.metadata.name,ATTACH:.spec.attachRequired,PODINFO:.spec.podInfoOnMount,MODES:.spec.volumeLifecycleModes'
# NAME              ATTACH   PODINFO   MODES
# ebs.csi.aws.com   true     false     [Persistent]

kubectl get csinodes -o custom-columns=\
'NODE:.metadata.name,DRIVER:.spec.drivers[*].name,NODEID:.spec.drivers[*].nodeID'
# NODE       DRIVER            NODEID
# worker01   ebs.csi.aws.com   i-0a1b2c3d4e5f
```

`csinodes` 에 노드가 없거나 `drivers` 가 비어 있으면 그 노드에서 그 드라이버의 볼륨을 쓸 수
없습니다. PVC는 `Bound` 인데 파드가 `ContainerCreating` 에서 멈추고 이벤트에
`node ... has no drivers registered` 가 나오는 경우, 원인은 그 노드에 CSI node
DaemonSet 파드가 안 떠 있는 것입니다.

**3~4) block 모드 PVC 와 파드**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: block-pvc, namespace: raw}
spec:
  storageClassName: csi-block
  volumeMode: Block
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 2Gi
---
apiVersion: v1
kind: Pod
metadata: {name: block-user, namespace: raw}
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeDevices:                                    # volumeMounts 가 아니다
    - {name: raw-disk, devicePath: /dev/xvdb}         # mountPath 가 아니다
  volumes:
  - name: raw-disk
    persistentVolumeClaim:
      claimName: block-pvc
```

**`volumeMode: Block` 볼륨은 `volumeMounts` 로 쓸 수 없습니다.** 컨테이너 스펙에서
`volumeDevices` + `devicePath` 를 써야 합니다. 필드 이름이 둘 다 있고 형태가 비슷해 습관대로
`volumeMounts`/`mountPath` 를 쓰면 kubelet이 파드를 시작하지 못하고
`volumeMode Block is not supported by volumeMounts` 계열 메시지를 냅니다. 반대로
`volumeMode: Filesystem`(기본값) 볼륨에 `volumeDevices` 를 쓰면 같은 식으로 거부됩니다.
둘은 PVC 쪽과 파드 쪽이 **짝을 맞춰야** 합니다.

`volumeMode` 는 PV/PVC 생성 이후에는 바꿀 수 없습니다. 잘못 만들었으면 지우고 다시 만듭니다.

**5) 증명.** block device는 `stat` 이 `block special file` 로, `ls -l` 은 첫 글자를 `b` 로
보고합니다. 파일시스템이 없으니 `df` 에는 나타나지 않습니다.

```bash
kubectl -n raw exec block-user -- ls -l /dev/xvdb
# brw-rw---- 1 root disk 259, 0 ... /dev/xvdb      ← 맨 앞 b
kubectl -n raw exec block-user -- stat -c '%F %t:%T' /dev/xvdb
# block special file 103:0
kubectl -n raw exec block-user -- sh -c 'df -h | grep xvdb || echo "not a filesystem"'
```

## 검증

```bash
kubectl -n raw get pvc block-pvc -o custom-columns=\
'NAME:.metadata.name,MODE:.spec.volumeMode,STATUS:.status.phase,CAP:.status.capacity.storage'
# NAME        MODE    STATUS  CAP
# block-pvc   Block   Bound   2Gi

kubectl -n raw get pod block-user            # Running
kubectl get pv -o custom-columns='NAME:.metadata.name,MODE:.spec.volumeMode'
# PV 쪽도 Block 이어야 바인딩된다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `volumeMode: Block` 은 파드에서 `volumeDevices` + `devicePath` 로 쓴다. `volumeMounts` + `mountPath` 는 `Filesystem` 전용이다.
- **헷갈리는 지점**: `csidrivers` 는 "이 드라이버가 클러스터에 있다"는 선언이고, `csinodes` 는 "이 노드에서 그 드라이버가 실제로 준비됐다"는 등록 기록입니다. 파드가 볼륨 때문에 안 뜨면 PVC가 `Bound` 인지 본 다음 `csinodes` 를 봅니다. 그리고 `accessModes` 와 `volumeMode` 는 전혀 다른 것입니다 — 앞은 몇 노드에서 동시에 쓸 수 있느냐, 뒤는 파일시스템이냐 raw 디바이스냐입니다.

## 참고 문서

- 검색어: `raw block volume support`
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#raw-block-volume-support
- https://kubernetes.io/docs/concepts/storage/volumes/#csi

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
