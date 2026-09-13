# q12 — Expand a PVC and observe reclaim behaviour · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `files` 에 StorageClass `slow` 를 쓰는 1Gi `Bound` 상태 PVC `archive` 와,
그것을 `/data` 에 마운트한 파드 `writer` 가 있다.

1. `slow` 가 온라인 확장을 허용하는지 판단한다. 허용하지 않으면 `slow` 와 동일하되 확장이
   허용되고 reclaim 정책이 `Retain` 인 새 StorageClass `slow-expand` 를 만든다.
2. `archive` 를 1Gi에서 3Gi로 확장한다. `writer` 내부 파일시스템이 새 크기를 인식하는지 확인한다.
3. `archive` 를 다시 1Gi로 줄이려 시도하고 정확한 오류를 기록한다.
4. PVC `scratch` (500Mi, `slow-expand` 사용)를 만들고 삭제한 뒤, 그 PV의 상태와 그 상태가 된
   이유를 보고한다.
5. 그 PV를 삭제하지 않고 다시 새 클레임에 쓸 수 있게 만든다.

## 모범 풀이

**1) 확장 허용 여부**

```bash
kubectl get sc slow -o jsonpath='{.allowVolumeExpansion}{"\n"}'     # 비어 있거나 false
kubectl get sc slow -o yaml > /tmp/slow.yaml
```

`allowVolumeExpansion` 은 StorageClass의 불변 필드가 아니므로 원칙적으로는 패치가 가능하지만,
문제가 새 클래스를 요구하므로 복사해서 만듭니다. 기존 클래스에서 `metadata` 의
`resourceVersion`, `uid`, `creationTimestamp` 를 지워야 apply가 통과합니다.

```yaml
# slow-expand.yaml  (provisioner / parameters 는 slow 의 값을 그대로 복사)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow-expand
provisioner: <slow 와 동일>
parameters: <slow 와 동일>
volumeBindingMode: <slow 와 동일>
reclaimPolicy: Retain
allowVolumeExpansion: true
```

```bash
kubectl apply -f slow-expand.yaml
```

**2) 확장**

```bash
kubectl -n files patch pvc archive -p '{"spec":{"resources":{"requests":{"storage":"3Gi"}}}}'
kubectl -n files get pvc archive
kubectl -n files describe pvc archive
```

기존 PVC `archive` 는 여전히 `slow` 에 묶여 있습니다. PVC의 `storageClassName` 은 바인드 후
변경할 수 없으므로, `slow` 가 확장을 허용하지 않으면 `archive` 자체는 확장할 수 없고
`slow` 에 `allowVolumeExpansion: true` 를 패치해야 합니다:

```bash
kubectl patch sc slow -p '{"allowVolumeExpansion":true}'
kubectl -n files patch pvc archive -p '{"spec":{"resources":{"requests":{"storage":"3Gi"}}}}'
```

`allowVolumeExpansion` 이 false면 패치가 즉시 거부됩니다
(`Forbidden: only dynamically provisioned pvc can be resized and the storageclass that provisions the pvc must support resize`).

확장이 시작되면 PVC에 `FileSystemResizePending` 컨디션이 붙을 수 있습니다. 파일시스템 확장은
CSI 드라이버가 노드에서 수행하므로 `status.capacity` 가 3Gi로 바뀌기까지 시간이 걸리고,
드라이버가 온라인 확장을 지원하지 않으면 **파드를 재시작해야** 반영됩니다.
`kubectl get pvc` 의 CAPACITY는 `status.capacity` 이고 요청값은 `spec.resources.requests` 라서,
두 값이 다르면 확장이 진행 중이라는 뜻입니다.

```bash
kubectl -n files exec writer -- df -h /data       # 3.0G
```

**3) 축소 시도**

```bash
kubectl -n files patch pvc archive -p '{"spec":{"resources":{"requests":{"storage":"1Gi"}}}}'
# The PersistentVolumeClaim "archive" is invalid: spec.resources.requests.storage:
# Forbidden: field can not be less than previous value
```

축소는 어떤 드라이버에서도 불가능합니다. API 서버 레벨에서 막습니다. 줄이려면 새 작은 PVC를
만들어 데이터를 복사해야 합니다.

**4~5) Retain과 Released**

```bash
kubectl -n files create -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: scratch
  namespace: files
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: slow-expand
  resources:
    requests:
      storage: 500Mi
EOF

kubectl -n files get pvc scratch                  # Bound, PV 이름 확인
PV=$(kubectl -n files get pvc scratch -o jsonpath='{.spec.volumeName}')
kubectl -n files delete pvc scratch
kubectl get pv $PV
# STATUS = Released, RECLAIM POLICY = Retain
```

`Retain` 이므로 PVC가 사라져도 PV와 그 안의 데이터가 남습니다. 상태는 `Available` 이 아니라
`Released` 입니다 — PV의 `spec.claimRef` 가 이미 없어진 PVC를 아직 가리키고 있기 때문입니다.
이 필드가 남아 있는 동안 PV는 다른 클레임에 절대 바인드되지 않습니다. 실수로 남의 데이터에
접근하는 것을 막는 안전장치입니다.

```bash
kubectl patch pv $PV --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
kubectl get pv $PV        # STATUS = Available
```

## 검증

```bash
kubectl get sc
# slow-expand   ...   Retain   ...   true      (ALLOWVOLUMEEXPANSION 칼럼)

kubectl -n files get pvc archive
# NAME      STATUS   CAPACITY   STORAGECLASS
# archive   Bound    3Gi        slow
kubectl -n files exec writer -- df -h /data | tail -1     # 3.0G

kubectl get pv $PV -o jsonpath='{.status.phase}{"\t"}{.spec.persistentVolumeReclaimPolicy}{"\n"}'
# Available   Retain
kubectl get pv $PV -o jsonpath='{.spec.claimRef}{"\n"}'   # 빈 출력
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 확장은 StorageClass의 `allowVolumeExpansion: true` 가 전제이고, 축소는 불가능하다.
- **헷갈리는 지점**: `Released` 와 `Available` 을 혼동하기 쉽습니다. `Available` 은 바로 쓸 수 있는
  상태, `Released` 는 "이전 클레임이 떠났지만 아직 회수되지 않음" 입니다. `Delete` 정책이면 PV가
  아예 사라지므로 `Released` 를 볼 일이 없고, `Released` 를 보게 되는 것은 `Retain` 일 때뿐입니다.
  그리고 `kubectl get pvc` 의 CAPACITY는 요청값이 아니라 실제 반영된 `status.capacity` 입니다.

## 참고 문서

- 검색어: `expanding persistent volume claims`
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#expanding-persistent-volumes-claims
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
