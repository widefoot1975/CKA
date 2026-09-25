# q12 — Claim storage and mount it in a Pod · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`data` 네임스페이스가 있다. StorageClass `local-path`(provisioner `rancher.io/local-path`, volumeBindingMode
`WaitForFirstConsumer`)를 쓸 수 있다.

1. `data` 에 StorageClass `local-path` 에서 `1Gi` 를 access mode `ReadWriteOnce` 로 요청하는
   PersistentVolumeClaim `app-data` 를 만든다. 이 PVC를 쓰는 파드가 없는 동안 `Pending` 인지 확인한다.
2. `data` 에 파드 `writer`(image `busybox:1.36`)를 만든다. PVC를 `/data` 에 마운트하고
   `sh -c 'date > /data/out.txt; sleep 3600'` 을 실행한다.
3. PVC가 이제 `Bound` 이고 파드 안의 `/data/out.txt` 에 날짜가 들어 있는지 확인한다.

## 모범 풀이

**1) PVC — 파드가 없으면 `Pending`**

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: data
spec:
  storageClassName: local-path
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 1Gi
```

```bash
kubectl apply -f pvc.yaml
kubectl -n data get pvc app-data              # STATUS Pending
kubectl -n data describe pvc app-data | tail -2
# Normal  WaitForFirstConsumer  ...  waiting for first consumer to be created before binding
```

**`Pending` 은 고장이 아닙니다 — 이 문제의 핵심입니다.** `WaitForFirstConsumer` 클래스는 PVC를 쓰는 파드가
스케줄될 때까지 볼륨을 만들지 않습니다. 파드가 노드에 배치되면 프로비저너가 **그 노드에** PV(`pvc-<uid>`)를
만들고 PVC와 바인딩합니다. local-path의 PV는 그 노드의 디렉터리이므로 PV에 node affinity가 붙고, 이 PVC를
쓰는 파드는 이후에도 항상 그 노드로만 갑니다.

**2) PVC를 마운트하는 파드** — 아래 파일을 `kubectl apply -f writer.yaml` 로 만듭니다.

```yaml
# writer.yaml
apiVersion: v1
kind: Pod
metadata:
  name: writer
  namespace: data
spec:
  containers:
  - name: writer
    image: busybox:1.36
    command: ["sh", "-c", "date > /data/out.txt; sleep 3600"]
    volumeMounts:
    - name: app-data              # 아래 volumes 의 이름
      mountPath: /data
  volumes:
  - name: app-data
    persistentVolumeClaim:
      claimName: app-data         # PVC 이름
```

## 검증

```bash
kubectl -n data get pod writer -o wide      # Running, NODE 열의 노드에 볼륨이 생겼다
kubectl -n data get pvc app-data
# NAME       STATUS   VOLUME        CAPACITY   ACCESS MODES   STORAGECLASS   ...
# app-data   Bound    pvc-3f1c...   1Gi        RWO            local-path     ...
kubectl get pv                              # CLAIM 열이 data/app-data, RECLAIM POLICY Delete
kubectl -n data exec writer -- cat /data/out.txt
# Sat Sep 26 10:30:00 UTC 2026
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `WaitForFirstConsumer` 클래스의 PVC는 파드가 생길 때까지 `Pending` 이 정상이다. 파드는 `volumes[].persistentVolumeClaim.claimName` 으로 PVC를 참조한다.
- **헷갈리는 지점**: `ReadWriteOnce` 는 "파드 하나"가 아니라 "**노드 하나**"에서 읽기·쓰기로 마운트할 수 있다는 뜻입니다. 같은 노드의 여러 파드는 함께 쓸 수 있고, 파드 하나로 제한하려면 `ReadWriteOncePod` 입니다. PVC는 파드와 같은 네임스페이스에 있어야 합니다.

## 참고 문서

- 검색어: `configure a pod to use a persistentvolume`
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
