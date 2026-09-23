# q12 — Expand a PVC and observe reclaim behaviour · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `files` 에 StorageClass `slow` 를 쓰는 1Gi `Bound` 상태 PVC `archive` 와,
그것을 `/data` 에 마운트한 파드 `writer` 가 있다. `slow` 뒤의 CSI 드라이버는 온라인 확장을 지원한다.

1. `slow` 가 볼륨 확장을 허용하는지 확인한다. `archive` 는 그 자리에서 확장해야 하므로, 허용하지 않으면
   필요한 것을 바꾼다 — 바인딩된 PVC는 다른 클래스로 옮길 수 없다.
2. `archive` 를 1Gi에서 3Gi로 확장하고, `writer` 를 재시작하지 않은 채 내부 파일시스템이 새 크기를
   인식하는지 확인한다.
3. `archive` 를 다시 1Gi로 줄이려 시도하고 정확한 오류를 기록한다.
4. `slow` 와 같되 reclaim 정책만 `Retain` 인 StorageClass `slow-retain` 을 만든다. 거기서 PVC
   `scratch`(500Mi)를 만들어 실제로 PV를 받게 한 뒤, 클레임을 지우고 그 PV의 상태와 이유를 보고한다.
5. 그 PV를 삭제하지 않고 다시 새 클레임에 쓸 수 있게 만든다.

## 모범 풀이

**1) 확장 허용 여부 — 클래스를 새로 만드는 것은 답이 아닙니다**

```bash
kubectl get sc slow -o jsonpath='{.allowVolumeExpansion}{"\n"}'     # 비어 있거나 false
kubectl -n files get pvc archive -o jsonpath='{.spec.storageClassName}{"\n"}'   # slow
```

PVC의 `storageClassName` 은 바인딩 후 바꿀 수 없으므로, 확장을 허용하는 새 클래스를 만들어도 `archive`
에는 아무 영향이 없습니다. 확장 허용 여부는 **그 PVC가 속한 클래스**가 정합니다. 다행히
`allowVolumeExpansion` 은 StorageClass에서 바꿀 수 있는 필드입니다(provisioner, parameters,
reclaimPolicy, volumeBindingMode 는 불변).

```bash
kubectl patch sc slow -p '{"allowVolumeExpansion":true}'
```

`allowVolumeExpansion` 은 "확장 요청을 받아 준다"는 허가일 뿐이고, **온라인으로(마운트된 채로) 늘릴 수
있는지는 CSI 드라이버의 능력**입니다. 클래스를 봐서는 알 수 없고 드라이버 문서로 확인합니다.

**2) 확장**

```bash
kubectl -n files patch pvc archive -p '{"spec":{"resources":{"requests":{"storage":"3Gi"}}}}'
kubectl -n files get pvc archive -w          # CAPACITY 가 3Gi 로 바뀔 때까지
kubectl -n files exec writer -- df -h /data  # 3.0G — writer 는 그대로 Running
```

`kubectl get pvc` 의 CAPACITY는 `status.capacity` 이고 요청값은 `spec.resources.requests` 라서,
두 값이 다르면 확장이 진행 중이라는 뜻입니다. 드라이버가 오프라인 확장만 지원한다면 PVC에
`FileSystemResizePending` 컨디션이 붙고 **파드를 재시작해야** 파일시스템이 늘어납니다.

`allowVolumeExpansion` 이 false인 상태로 패치하면 즉시 거부됩니다
(`Forbidden: only dynamically provisioned pvc can be resized and the storageclass that provisions the pvc must support resize`).

**3) 축소 시도**

```bash
kubectl -n files patch pvc archive -p '{"spec":{"resources":{"requests":{"storage":"1Gi"}}}}'
# The PersistentVolumeClaim "archive" is invalid: spec.resources.requests.storage: Forbidden: ...
```

실제 용량(`status.capacity`) 아래로 줄이는 것은 어떤 드라이버에서도 불가능하고 API server가 막습니다.
1.34부터 GA인 RecoverVolumeExpansionFailure 덕분에 **확장이 실패했을 때에 한해** 요청을
`status.capacity` 보다 큰 값까지는 낮출 수 있지만, 여기처럼 이미 3Gi로 늘어난 뒤에는 거부됩니다.
에러 문구는 버전에 따라 조금씩 다르므로 문제의 요구대로 **실제 출력**을 그대로 기록합니다. 줄이려면
새 작은 PVC를 만들어 데이터를 복사해야 합니다.

**4) Retain 클래스와 Released**

```bash
kubectl get sc slow -o yaml > /tmp/slow-retain.yaml
# name 을 slow-retain 으로, reclaimPolicy 를 Retain 으로 바꾸고
# metadata 의 uid, resourceVersion, creationTimestamp, default-class 어노테이션은 지운다
kubectl apply -f /tmp/slow-retain.yaml
kubectl get sc slow-retain -o jsonpath='{.reclaimPolicy} {.volumeBindingMode}{"\n"}'
# Retain WaitForFirstConsumer    ← 이 경우 소비자 파드가 있어야 PV가 생긴다
```

**`WaitForFirstConsumer` 클래스는 파드가 PVC를 쓰기 전까지 PV를 만들지 않습니다.** PVC만 만들고
지우면 PV가 생긴 적이 없으니 관찰할 것이 없습니다. 그래서 잠깐 쓰는 파드를 붙입니다.

```bash
kubectl -n files apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: { name: scratch }
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: slow-retain
  resources: { requests: { storage: 500Mi } }
---
apiVersion: v1
kind: Pod
metadata: { name: scratch-user }
spec:
  containers:
  - name: c
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts: [{ name: v, mountPath: /data }]
  volumes:
  - name: v
    persistentVolumeClaim: { claimName: scratch }
EOF

kubectl -n files get pvc scratch -w                      # Bound 가 되면 Ctrl-C
PV=$(kubectl -n files get pvc scratch -o jsonpath='{.spec.volumeName}')
kubectl -n files delete pod scratch-user
kubectl -n files delete pvc scratch
kubectl get pv $PV
# STATUS = Released, RECLAIM POLICY = Retain
```

`Retain` 이므로 PVC가 사라져도 PV와 그 안의 데이터가 남습니다. 상태는 `Available` 이 아니라
`Released` 입니다 — PV의 `spec.claimRef` 가 이미 없어진 PVC를 아직 가리키고 있기 때문입니다.
이 필드가 남아 있는 동안 PV는 다른 클레임에 바인드되지 않습니다. 실수로 남의 데이터에 접근하는 것을
막는 안전장치입니다.

**5) 다시 Available 로**

```bash
kubectl patch pv $PV --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
kubectl get pv $PV        # STATUS = Available
```

## 검증

```bash
kubectl get sc slow -o jsonpath='{.allowVolumeExpansion}{"\n"}'      # true
kubectl get sc slow-retain                                           # RECLAIMPOLICY Retain

kubectl -n files get pvc archive
# NAME      STATUS   CAPACITY   STORAGECLASS
# archive   Bound    3Gi        slow
kubectl -n files exec writer -- df -h /data | tail -1     # 3.0G
kubectl -n files get pod writer                           # RESTARTS 그대로

kubectl get pv $PV -o jsonpath='{.status.phase}{"\t"}{.spec.persistentVolumeReclaimPolicy}{"\n"}'
# Available   Retain
kubectl get pv $PV -o jsonpath='{.spec.claimRef}{"\n"}'   # 빈 출력
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 확장 허용 여부는 PVC가 **속한** 클래스의 `allowVolumeExpansion` 이 정하고, 이 필드는 기존 클래스에서 패치할 수 있다. 온라인 확장 가능 여부는 드라이버 능력이다. 실제 용량 아래로 줄이는 것은 불가능하다.
- **헷갈리는 지점**: `Released` 와 `Available` 을 혼동하기 쉽습니다. `Available` 은 바로 쓸 수 있는
  상태, `Released` 는 "이전 클레임이 떠났지만 아직 회수되지 않음" 입니다. `Delete` 정책이면 보통 PV가
  곧 삭제되고, 삭제에 실패하면 `Failed` 로 남습니다(A-q12). 그리고 `WaitForFirstConsumer` 클래스에서는
  파드가 붙기 전까지 PVC가 `Pending` 이고 PV도 없습니다.

## 참고 문서

- 검색어: `expanding persistent volume claims`
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#expanding-persistent-volumes-claims
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming
- https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
