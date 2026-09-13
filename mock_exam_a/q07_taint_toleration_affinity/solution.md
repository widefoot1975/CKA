# q07 — Place pods with taints, tolerations and node affinity · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

배치 작업은 일반 워커 풀에서 떼어내 전용 노드 한 대에 몰아야 한다.

1. 노드 `worker02` 에 `workload=batch:NoSchedule` taint를 걸고 `tier=batch` 라벨을 붙인다.
2. `default` 에 `busybox:1.36` 이미지로 `sleep 3600` 을 실행하는 Pod `batch-runner` 를 만든다. 이 파드는 그 taint를 tolerate하면서 `tier=batch` 라벨이 있는 노드에**만** 스케줄될 수 있어야 한다. `nodeSelector` 가 아니라 node affinity를 쓴다.
3. `nginx:1.27` 을 실행하는 Pod `web-front` 를 만든다. `tier=web` 라벨 노드를 weight 50으로 선호하지만, 그런 노드가 없어도 스케줄은 되어야 한다.
4. 각 파드가 어디에 떨어졌는지 확인하고, `batch-runner` 에 toleration만 줬다면 왜 부족했는지 한 줄로 적는다.
5. `worker02` 의 taint를 제거하고 없어진 것을 확인한다.

## 모범 풀이

```bash
kubectl taint node worker02 workload=batch:NoSchedule
kubectl label node worker02 tier=batch
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: batch-runner
spec:
  tolerations:
  - key: workload
    operator: Equal
    value: batch
    effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: tier
            operator: In
            values: ["batch"]
  containers:
  - name: runner
    image: busybox:1.36
    command: ["sleep", "3600"]
```

`web-front` 은 affinity 블록만 다릅니다.

```yaml
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 50
        preference:
          matchExpressions:
          - key: tier
            operator: In
            values: ["web"]
```

**toleration은 허가일 뿐 유인이 아닙니다.** taint는 "이 노드는 나를 tolerate하지 않는 파드를 받지 않는다"는 노드 쪽 거부 장치이고, toleration은 그 거부를 면제받는 것뿐입니다. toleration만 있는 파드는 `worker02` 에 갈 수 **있게** 되었을 뿐이고, 스케줄러는 조건을 만족하는 아무 노드에나 보냅니다. 특정 노드로 **끌어당기려면** `nodeSelector` 나 node affinity가 따로 필요합니다. 그래서 전용 노드 패턴은 항상 taint + toleration + affinity 세 개가 한 묶음입니다.

required와 preferred의 구조가 다릅니다.

| | 구조 | 만족하는 노드가 없으면 |
|---|---|---|
| `required...` | `nodeSelectorTerms` 리스트 (OR), 각 term의 `matchExpressions` 는 AND | 파드가 `Pending` |
| `preferred...` | `weight` + `preference` 쌍의 리스트 | 점수만 잃고 다른 노드에 스케줄됨 |

이름 뒤의 `IgnoredDuringExecution` 은 **이미 실행 중인 파드는 노드 라벨이 나중에 바뀌어도 쫓겨나지 않는다**는 뜻입니다. 반대로 taint의 `NoExecute` effect는 실행 중인 파드까지 축출합니다(`tolerationSeconds` 로 유예 가능).

**taint 제거**는 끝에 하이픈을 붙입니다.

```bash
kubectl taint node worker02 workload=batch:NoSchedule-   # 이 effect만 제거
kubectl taint node worker02 workload-                    # 이 키의 모든 taint 제거
```

## 검증

```bash
kubectl describe node worker02 | grep -i -A2 taints   # workload=batch:NoSchedule
kubectl get node -L tier                              # worker02 의 TIER 열이 batch
kubectl get pod batch-runner web-front -o wide
# batch-runner → worker02, web-front → 아무 노드나 (둘 다 Running)
kubectl describe node worker02 | grep -i taints       # 제거 후 Taints: <none>
```

`batch-runner` 가 `Pending` 이면 이벤트 문장이 원인을 알려줍니다. `didn't match Pod's node affinity/selector` 는 라벨 문제, `had untolerated taint` 는 toleration 문제입니다.

```bash
kubectl describe pod batch-runner | tail -5
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: toleration은 "갈 수 있게" 해줄 뿐이고 "가게" 만들지 않는다. 전용 노드는 taint + toleration + affinity 세 개가 필요하다.
- **헷갈리는 지점**: `nodeSelector` 는 `spec.nodeSelector` 아래 단순 맵이고, node affinity는 `spec.affinity.nodeAffinity` 아래 `matchExpressions` 구조입니다. affinity는 `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt` 를 쓸 수 있고 nodeSelector는 완전 일치만 됩니다. 그리고 required는 `nodeSelectorTerms`, preferred는 `preference` — 필드 이름이 다릅니다.

## 참고 문서

- 검색어: `taints and tolerations`
- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
