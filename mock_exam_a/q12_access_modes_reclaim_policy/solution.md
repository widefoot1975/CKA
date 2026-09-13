# q12 — Access modes and reclaim policy · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클레임을 실수로 삭제했고, 데이터를 잃지 않고 그 볼륨을 다시 써야 한다.

1. 클래스 `slow` 에 1Gi `ReadWriteOnce` PersistentVolume 두 개를 만든다. `pv-retain` 은 반환 정책 `Retain`, hostPath `/mnt/data/retain`. `pv-delete` 는 반환 정책 `Delete`, hostPath `/mnt/data/delete`.
2. `ops` 네임스페이스에 `pv-retain` 에 바인딩되는 클레임 `pvc-a` 를 만들고, Pod `writer`(`busybox:1.36`)로 파일을 하나 쓴 뒤 파드와 클레임을 삭제한다.
3. 이제 `pv-retain` 의 `STATUS` 를 보고한다. PV를 삭제하지 않고 파일도 잃지 않은 채 새 클레임이 바인딩될 수 있도록 `Available` 로 되돌린다.
4. `ops` 에 클래스 `slow` 에서 `ReadWriteMany` 를 요청하는 클레임 `pvc-rwx` 를 만들고, 왜 바인딩되지 않는지 한 줄로 적는다.
5. PV가 가질 수 있는 반환 정책을 모두 나열하고 어느 것이 deprecated인지 말한다.

## 모범 풀이

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-retain
spec:
  capacity: { storage: 1Gi }
  accessModes: ["ReadWriteOnce"]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: slow
  hostPath: { path: /mnt/data/retain }
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-delete
spec:
  capacity: { storage: 1Gi }
  accessModes: ["ReadWriteOnce"]
  persistentVolumeReclaimPolicy: Delete
  storageClassName: slow
  hostPath: { path: /mnt/data/delete }
```

```bash
kubectl -n ops create -f pvc-a.yaml     # accessModes RWO, class slow, 1Gi
kubectl -n ops run writer --image=busybox:1.36 --restart=Never \
  --overrides='{"spec":{"containers":[{"name":"writer","image":"busybox:1.36","command":["sh","-c","echo keepme > /data/f.txt; sleep 3600"],"volumeMounts":[{"name":"v","mountPath":"/data"}]}],"volumes":[{"name":"v","persistentVolumeClaim":{"claimName":"pvc-a"}}]}}'
kubectl -n ops delete pod writer
kubectl -n ops delete pvc pvc-a
kubectl get pv pv-retain        # STATUS: Released
```

**`Retain` PV는 PVC를 지워도 `Available` 로 돌아가지 않고 `Released` 에 머무릅니다.** 그리고 `Released` 상태로는 새 클레임이 바인딩되지 않습니다. 이유는 PV의 `spec.claimRef` 가 이미 삭제된 PVC(이름 + UID)를 그대로 가리키고 있어서, 컨트롤러가 "이 볼륨은 아직 임자가 있다"고 보기 때문입니다. 데이터를 지키려는 정책이므로 사람이 직접 판단해 참조를 끊어 줘야 합니다.

```bash
kubectl get pv pv-retain -o jsonpath='{.spec.claimRef}'      # 삭제된 ops/pvc-a 가 남아 있다
kubectl patch pv pv-retain -p '{"spec":{"claimRef":null}}'
kubectl get pv pv-retain        # STATUS: Available
```

`kubectl edit pv pv-retain` 으로 `claimRef` 블록을 지워도 같습니다. hostPath 디렉터리는 건드리지 않았으므로 `/mnt/data/retain/f.txt` 가 그대로 남아 새 클레임이 이어받습니다. 반면 `pv-delete` 쪽은 PVC를 지우면 PV 오브젝트까지 자동으로 사라집니다. 다만 실제 스토리지 삭제는 플러그인이 deleter를 구현한 경우에만 일어납니다 — hostPath에는 deleter가 없어서 PV 오브젝트만 없어지고 노드의 디렉터리는 남습니다.

**반환 정책**

| 정책 | PVC 삭제 후 | 비고 |
|---|---|---|
| `Retain` | PV는 `Released` 로 남고 데이터 보존 | `claimRef` 를 비워야 재사용 가능 |
| `Delete` | PV 오브젝트와 (지원 시) 실제 볼륨까지 삭제 | 동적 프로비저닝의 기본값 |
| `Recycle` | 볼륨을 `rm -rf` 로 비우고 `Available` 로 | **deprecated** — 쓰지 않는다 |

**액세스 모드**

| 모드 | 약어 | 의미 |
|---|---|---|
| `ReadWriteOnce` | RWO | **노드 하나**에서 읽기·쓰기 |
| `ReadOnlyMany` | ROX | 여러 노드에서 읽기 전용 |
| `ReadWriteMany` | RWX | 여러 노드에서 읽기·쓰기 |
| `ReadWriteOncePod` | RWOP | **파드 하나**에서만 읽기·쓰기 |

`pvc-rwx` 가 바인딩되지 않는 이유는 `slow` 클래스에 `ReadWriteMany` 를 제공하는 PV가 없기 때문입니다. PVC가 요청한 모드는 PV의 `accessModes` 목록에 포함되어야 하며, 모드는 다운그레이드되지 않습니다(RWO PV가 RWX 요청을 받아주지 않습니다).

## 검증

```bash
kubectl get pv
# pv-retain  1Gi  RWO  Retain  Available  slow
# pv-delete  ...  (Delete 실습을 했다면 사라져 있음)

kubectl -n ops get pvc pvc-rwx
# pvc-rwx   Pending   ...   slow
kubectl -n ops describe pvc pvc-rwx | tail -4      # no persistent volumes available

cat /mnt/data/retain/f.txt        # keepme — pv-retain 이 붙은 노드에서, 데이터가 살아 있다
kubectl -n ops apply -f pvc-b.yaml
kubectl get pv pv-retain          # STATUS Bound, CLAIM ops/pvc-b — 새 클레임이 이어받았다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `Retain` PV는 PVC 삭제 후 `Released` 에 머문다. `spec.claimRef` 를 비워야(`kubectl patch pv X -p '{"spec":{"claimRef":null}}'`) `Available` 이 되어 재사용된다.
- **헷갈리는 지점**: `ReadWriteOnce` 는 "파드 하나"가 아니라 **"노드 하나"** 입니다. 같은 노드에 뜬 파드 여러 개는 RWO 볼륨을 동시에 마운트할 수 있습니다. 파드 하나로 제한하려면 `ReadWriteOncePod` 를 씁니다. 또 `Released` 와 `Available` 을 눈으로 구분하지 않고 넘어가면 새 PVC가 왜 `Pending` 인지 못 찾습니다.

## 참고 문서

- 검색어: `persistent volumes reclaiming`
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
