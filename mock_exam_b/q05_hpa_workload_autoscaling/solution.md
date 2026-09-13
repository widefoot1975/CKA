# q05 — Configure workload autoscaling with an HPA · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`web` 네임스페이스에 deployment `frontend`(image `nginx:1.27`, replica 1)가 있고 리소스 필드가
설정되어 있지 않다. 담당자는 자신이 만든 HPA의 CPU가 `<unknown>` 으로 나온다고 한다.

1. 디스크의 매니페스트 파일을 고치지 않고 `frontend` 컨테이너에 CPU request `100m`,
   CPU limit `200m` 을 준다.
2. `web` 에 `autoscaling/v2` HorizontalPodAutoscaler `frontend-hpa` 를 만든다. 대상은
   `frontend` deployment, `minReplicas: 2`, `maxReplicas: 8`, 평균 CPU **utilization**
   `60%` 기준으로 스케일한다.
3. HPA의 `TARGETS` 열이 `<unknown>` 이 아닌 실제 퍼센트를 보이고 replica가 2로 안정되는지 확인한다.
4. `averageUtilization` 메트릭이 계산되기 위해 먼저 성립해야 하는 두 가지 전제조건을
   `/opt/q05/answer.txt` 에 적는다.

## 모범 풀이

**1) 리소스 주입.** `kubectl set resources` 가 있습니다. `edit` 보다 빠르고 오타가 없습니다.

```bash
kubectl -n web set resources deploy frontend \
  --containers=nginx --requests=cpu=100m --limits=cpu=200m
```

컨테이너 이름을 모르면 먼저 확인합니다. `--containers='*'` 도 됩니다.

```bash
kubectl -n web get deploy frontend -o jsonpath='{.spec.template.spec.containers[*].name}'
```

**2) HPA.** imperative 한 줄이면 끝나고, 최신 kubectl은 `autoscaling/v2` 오브젝트를 만듭니다.

```bash
kubectl -n web autoscale deploy frontend --cpu-percent=60 --min=2 --max=8 --name=frontend-hpa
```

yaml로 쓸 때의 형태는 이렇습니다. `type: Resource` 와 `target.type: Utilization` 이 짝이고,
`averageUtilization` 은 `target` **안**에 들어갑니다.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-hpa
  namespace: web
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  minReplicas: 2
  maxReplicas: 8
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
```

**`<unknown>` 의 원인은 거의 항상 `requests` 누락입니다.** `Utilization` 은 실제 사용량을
컨테이너의 **`requests.cpu` 로 나눈 비율**입니다. limit이 아닙니다. request가 없으면 나눌 값이
없으니 HPA는 비율을 만들 수 없고, `kubectl describe hpa` 의 조건에
`missing request for cpu` 가 뜹니다. 절대값으로 가고 싶다면 `target.type: AverageValue` +
`averageValue: 50m` 을 쓰면 request가 없어도 동작합니다.

두 번째 전제는 metrics-server입니다. `metrics.k8s.io` API가 없으면 HPA는
`unable to get metrics for resource cpu` 로 같은 `<unknown>` 을 보여줍니다. 그래서 답은:
**컨테이너에 `requests.cpu` 가 있어야 하고, metrics-server가 동작해 `metrics.k8s.io` 를
서비스해야 한다.**

## 검증

```bash
kubectl -n web get hpa frontend-hpa
# NAME           REFERENCE             TARGETS        MINPODS  MAXPODS  REPLICAS
# frontend-hpa   Deployment/frontend   cpu: 0%/60%    2        8        2

kubectl -n web describe hpa frontend-hpa | grep -A3 Conditions
# ScalingActive  True  ValidMetricFound

kubectl -n web get deploy frontend      # READY 2/2
kubectl top pod -n web                  # metrics-server 가 살아있는지 교차 확인
kubectl -n web get hpa frontend-hpa -o jsonpath='{.apiVersion}'   # autoscaling/v2
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `Utilization` 은 `requests` 대비 비율이다. `requests.cpu` 가 없으면 HPA는 영원히 `<unknown>` 이다.
- **헷갈리는 지점**: `target.type` 의 세 값이 다릅니다 — `Utilization` 은 request 대비 퍼센트, `AverageValue` 는 파드당 절대값, `Value` 는 전체 합계 절대값. 그리고 `minReplicas: 2` 를 준 HPA는 deployment의 replica가 1이어도 즉시 2로 올립니다. HPA와 `kubectl scale` 을 동시에 쓰면 HPA가 이깁니다.

## 참고 문서

- 검색어: `horizontal pod autoscaling`
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
