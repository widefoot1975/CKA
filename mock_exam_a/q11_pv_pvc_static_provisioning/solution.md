# q11 — Static PersistentVolume provisioning · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

이 클러스터에는 동적 프로비저너가 없어 볼륨을 손으로 준비해야 한다.

1. `worker01` 에 디렉터리 `/mnt/data/logs` 를 만든다.
2. PersistentVolume `pv-logs` 를 만든다. 용량 2Gi, 액세스 모드 `ReadWriteOnce`, `storageClassName: manual`, 반환 정책 `Retain`, 스토리지는 `hostPath` `/mnt/data/logs`.
3. `ops` 네임스페이스에 스토리지 클래스 `manual` 에서 1Gi `ReadWriteOnce` 를 요청하는 PersistentVolumeClaim `pvc-logs` 를 만들고, `pv-logs` 에 바인딩되는지 확인한다.
4. `ops` 에 `busybox:1.36` 으로 `sh -c 'while true; do date >> /data/out.log; sleep 5; done'` 를 실행하는 Pod `logger` 를 만들어 클레임을 `/data` 에 마운트한다. 노드에서 파일이 쓰이는 것을 보인다.
5. `ops` 에 `manual` 에서 3Gi를 요청하는 두 번째 클레임 `pvc-logs-2` 를 만들고, 왜 `Pending` 으로 남는지 한 줄로 적는다.

## 모범 풀이

```bash
# worker01 에서
mkdir -p /mnt/data/logs
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata: { name: pv-logs }
spec:
  capacity: { storage: 2Gi }
  accessModes: ["ReadWriteOnce"]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath: { path: /mnt/data/logs }
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: { name: pvc-logs, namespace: ops }
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: manual
  resources:
    requests: { storage: 1Gi }
---
apiVersion: v1
kind: Pod
metadata: { name: logger, namespace: ops }
spec:
  containers:
  - name: logger
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date >> /data/out.log; sleep 5; done"]
    volumeMounts:
    - { name: logs, mountPath: /data }
  volumes:
  - name: logs
    persistentVolumeClaim: { claimName: pvc-logs }
```

**바인딩에는 세 조건이 동시에 맞아야 합니다.**

| 조건 | 기준 |
|---|---|
| 액세스 모드 | PVC가 요청한 모드가 PV가 제공하는 모드 목록에 **포함**되어야 한다 |
| `storageClassName` | 두 값이 **문자열로 정확히 일치**해야 한다 |
| 용량 | PV의 `capacity` ≥ PVC의 `requests.storage` |

용량은 같지 않아도 되고 PV가 크면 됩니다. 다만 바인딩되면 PVC는 PV 전체를 차지합니다 — 2Gi PV에 1Gi를 요청해 바인딩하면 남은 1Gi를 다른 클레임이 쓸 수 없습니다. 그래서 `pvc-logs-2` 는 3Gi를 만족하는 PV가 없어 `Pending` 입니다. `manual` 클래스에는 프로비저너가 없으니 동적으로 만들어지지도 않습니다.

**`storageClassName` 을 생략하는 것과 `""` 로 두는 것은 다릅니다.** 필드를 아예 쓰지 않으면 클러스터의 **기본 StorageClass**가 적용되고, 기본 클래스가 있으면 동적 프로비저닝이 일어나 방금 만든 `pv-logs` 를 무시한 새 볼륨이 생깁니다. `storageClassName: ""` 는 "클래스를 쓰지 않겠다"는 명시적 선언이라 클래스가 없는 PV에만 바인딩됩니다. 정적 프로비저닝 문제에서 클래스 이름을 맞추거나 양쪽 모두 `""` 로 두는 것이 핵심입니다.

```bash
kubectl get storageclass          # (default) 표시가 붙은 클래스가 있는지 확인
```

hostPath PV는 특정 노드의 로컬 디렉터리라 파드가 반드시 그 노드에 떠야 합니다. 실무라면 `nodeAffinity` 를 붙인 `local` 볼륨을 쓰지만, 시험 범위에서는 hostPath로 충분합니다.

## 검증

```bash
kubectl get pv pv-logs
# NAME     CAPACITY  ACCESS MODES  RECLAIM POLICY  STATUS  CLAIM          STORAGECLASS
# pv-logs  2Gi       RWO           Retain          Bound   ops/pvc-logs   manual

kubectl -n ops get pvc
# pvc-logs    Bound     pv-logs   2Gi   RWO   manual      # CAPACITY는 PV의 2Gi로 표시
# pvc-logs-2  Pending                         manual

kubectl -n ops describe pvc pvc-logs-2 | tail -5
# Events: ... no persistent volumes available for this claim

kubectl -n ops exec logger -- tail -3 /data/out.log
kubectl -n ops get pod logger -o wide           # 어느 노드인지 확인
tail -3 /mnt/data/logs/out.log                  # 그 노드에서
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 바인딩 조건은 accessModes 포함 + storageClassName 완전 일치 + PV capacity ≥ PVC request, 세 개 전부.
- **헷갈리는 지점**: `storageClassName` 을 **생략**하면 기본 StorageClass가 끼어들어 동적 프로비저닝이 되고, `""` 로 두면 클래스 없는 PV만 노립니다. 둘이 전혀 다릅니다. 그리고 PVC가 `Pending` 일 때 원인은 항상 `kubectl describe pvc` 의 Events에 문장으로 적혀 있으니 추측하지 말고 읽습니다.

## 참고 문서

- 검색어: `configure persistent volume storage`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
