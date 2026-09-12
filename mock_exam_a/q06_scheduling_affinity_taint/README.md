# q06 — taint/toleration + nodeAffinity 배치

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Workloads & Scheduling (15%) |
| 배점 | 5 |
| 컨텍스트 | `kubectl config use-context k8s-c1` |
| 목표 시간 | 8분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

1. 노드 `worker01` 에 label `disktype=ssd` 를, taint `gpu=true:NoSchedule` 을 설정한다.
2. 파드 `gpu-workload` 를 만든다. 이미지는 `nginx`. 이 파드는
   - `gpu=true:NoSchedule` taint를 **견딜 수 있어야** 하고,
   - `disktype=ssd` label이 있는 노드에만 스케줄되어야 한다 (필수 조건, 선호가 아님).
3. 파드 `plain-workload` 를 같은 이미지로 만든다. 아무 toleration도 주지 않는다.
4. `gpu-workload` 는 `worker01` 에 뜨고, `plain-workload` 는 `worker01` 이 아닌 곳에 뜨는지 확인한다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 직접 풀고 나서 펼치세요</summary>

```bash
kubectl label node worker01 disktype=ssd
kubectl taint node worker01 gpu=true:NoSchedule
```

`gpu-workload.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-workload
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: gpu
    operator: Equal
    value: "true"
    effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values: ["ssd"]
```

```bash
kubectl apply -f gpu-workload.yaml
kubectl run plain-workload --image=nginx
```

**toleration과 affinity는 역할이 다릅니다.** toleration은 "taint가 있어도 거부당하지 않게" 해 줄 뿐, 그 노드로 **끌어당기지는 않습니다**. 특정 노드에 반드시 보내려면 nodeAffinity(또는 nodeSelector)가 따로 필요합니다. 둘 중 하나만 쓰면 이 문제는 부분 점수입니다.

간단히 label만으로 충분하다면 affinity 대신 `nodeSelector: {disktype: ssd}` 도 정답입니다.

</details>

## 검증

```bash
kubectl get pod gpu-workload -o wide      # NODE 가 worker01
kubectl get pod plain-workload -o wide    # NODE 가 worker01 이 아님
kubectl describe node worker01 | grep -A3 Taints
kubectl describe node worker01 | grep -i disktype
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: toleration = 거부당하지 않음, affinity/nodeSelector = 그곳으로 보냄. 두 개는 짝이다.
- **헷갈리는 지점**: `required...` 는 필수, `preferred...` 는 선호. 문제에 "only", "must" 가 있으면 required.

## 참고 문서

- 검색어: `taints and tolerations` / `assign pod node`
- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
