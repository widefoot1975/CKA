# q12 — Dynamic provisioning and PVC expansion · 풀이

← 문제: **[question.md](question.md)**

## 모범 풀이

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-local
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Delete
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast-local
  resources:
    requests:
      storage: 1Gi
```

**확장**

```bash
kubectl patch pvc app-pvc -p '{"spec":{"resources":{"requests":{"storage":"3Gi"}}}}'
```

`WaitForFirstConsumer` 는 **PVC를 쓰는 파드가 스케줄될 때까지 바인딩을 미룹니다.** 그래서 PVC만 만들면 `Pending` 이 정상이고, 파드를 만들면 `Bound` 로 넘어갑니다. 이걸 모르면 "PVC가 Pending이다"를 오류로 오해합니다.

확장은 `allowVolumeExpansion: true` 인 StorageClass로 만든 PVC만 가능하고, **줄이는 것은 불가능**합니다.

## 검증

```bash
kubectl get sc                                  # fast-local 에 (default) 표시
kubectl get pvc app-pvc                         # 파드 생성 전 Pending → 후 Bound
kubectl get pod app-pod
kubectl get pvc app-pvc -o jsonpath='{.status.capacity.storage}'; echo    # 3Gi
kubectl describe pvc app-pvc | tail -10         # 확장 진행 상황
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 기본 StorageClass 지정은 annotation `storageclass.kubernetes.io/is-default-class: "true"`. 값이 **문자열** `"true"` 입니다.
- **헷갈리는 지점**: `WaitForFirstConsumer` 에서 PVC가 Pending인 건 정상. `Immediate` 와 혼동하지 마세요.

## 참고 문서

- 검색어: `storage class` / `expanding persistent volume claims`
- https://kubernetes.io/docs/concepts/storage/storage-classes/
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#expanding-persistent-volumes-claims

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
