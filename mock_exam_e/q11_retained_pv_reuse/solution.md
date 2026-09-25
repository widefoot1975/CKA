# q11 — Reattach a retained volume to a new Deployment · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`finance` 네임스페이스의 Deployment `ledger` 와 그 PVC가 실수로 삭제되었다. 데이터는
PersistentVolume `ledger-pv`(`250Mi`, `ReadWriteOnce`, storageClassName `manual`, reclaim policy
`Retain`)에 남아 있고, 관리자가 이미 이 PV를 다시 `Available` 상태로 만들어 두었다. Deployment
매니페스트 사본은 `/opt/course/e11/ledger-deploy.yaml` 에 있다.

1. `finance` 네임스페이스에 정확히 `ledger-pv` 에 바인딩되는 PersistentVolumeClaim `ledger`
   (`ReadWriteOnce`, `250Mi`, storageClassName `manual`)를 만든다.
2. `/opt/course/e11/ledger-deploy.yaml` 을 수정해 컨테이너가 PVC `ledger` 를 `/var/lib/ledger` 에
   마운트하게 한 뒤 적용한다.
3. PVC `ledger` 가 `ledger-pv` 에 `Bound` 이고 `ledger` 파드가 `Running` 인지 확인한다.

## 모범 풀이

**1) PV를 지정한 PVC** — 먼저 `kubectl get pv ledger-pv` 로 `Available`, class `manual` 을 확인합니다.
`spec.volumeName` 이 PVC를 특정 PV에 고정하는 필드입니다.

```yaml
# ledger-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ledger
  namespace: finance
spec:
  storageClassName: manual       # PV 와 같아야 한다
  volumeName: ledger-pv          # 이 PV 에만 바인딩
  accessModes: ["ReadWriteOnce"]
  resources: {requests: {storage: 250Mi}}
```

바인딩 조건은 PV가 `Available`, storageClassName 동일, accessModes 일치, PV 용량 ≥ 요청량입니다.
`storageClassName` 을 빼면 class가 `manual` 과 달라져(기본 StorageClass가 있으면 그 이름이 채워짐) `Pending` 에 머뭅니다.

**2) Deployment 매니페스트** — 주어진 파일(예시)에 `volumeMounts` 와 `volumes` 두 곳을 추가합니다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger, namespace: finance}
spec:
  replicas: 1
  selector: {matchLabels: {app: ledger}}
  template:
    metadata: {labels: {app: ledger}}
    spec:
      containers:
      - name: ledger
        image: busybox:1.36
        command: ["sh", "-c", "date >> /var/lib/ledger/boot.log; sleep 3600"]
        volumeMounts:              # ← 추가
        - name: data
          mountPath: /var/lib/ledger
      volumes:                     # ← 추가 (containers 와 같은 들여쓰기)
      - name: data
        persistentVolumeClaim:
          claimName: ledger
```

```bash
kubectl apply -f ledger-pvc.yaml
kubectl apply -f /opt/course/e11/ledger-deploy.yaml
```

**PV가 `Released` 였다면** — `Retain` PV는 PVC가 지워지면 `Released` 가 되고, `spec.claimRef` 에 옛 PVC
정보가 남아 새 PVC와 바인딩되지 않습니다. 이때는 `claimRef` 를 지워 `Available` 로 만듭니다(데이터는 남음).

```bash
kubectl patch pv ledger-pv --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
```

## 검증

```bash
kubectl -n finance get pvc ledger               # STATUS Bound, VOLUME ledger-pv, STORAGECLASS manual
kubectl get pv ledger-pv                        # STATUS Bound, CLAIM finance/ledger
kubectl -n finance get pods -l app=ledger       # Running
kubectl -n finance exec deploy/ledger -- ls /var/lib/ledger    # 예전 파일도 보인다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 특정 PV를 다시 쓰려면 PVC에 `volumeName` 과 같은 `storageClassName` 을 준다. `Released` PV는 `spec.claimRef` 를 지워야 `Available` 이 된다.
- **헷갈리는 지점**: `Retain` 은 "PVC가 지워져도 PV와 데이터를 남긴다"는 뜻이지 "자동으로 다시 쓸 수 있다"는 뜻이 아닙니다. `volumeName` 은 PV를 지정할 뿐이라 class·용량·accessModes가 안 맞으면 여전히 `Pending` 이고, 이유는 `kubectl -n finance describe pvc ledger` 의 이벤트에 나옵니다.

## 참고 문서

- 검색어: `persistent volumes reserving a persistentvolume`
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
