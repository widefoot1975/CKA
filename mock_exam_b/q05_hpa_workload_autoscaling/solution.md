# q05 — Configure workload autoscaling with an HPA · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`web` 네임스페이스에 deployment `frontend`(image `nginx:1.27`, replica 1)가 있고 리소스 필드가
설정되어 있지 않다. 담당자는 자신이 만든 HPA의 CPU가 `<unknown>` 으로 나온다고 한다.

1. 디스크의 매니페스트 파일을 고치지 않고 `frontend` 컨테이너에 CPU request `100m`,
   CPU limit `200m` 을 준다.
2. `web` 에 `autoscaling/v2` HorizontalPodAutoscaler `frontend-hpa` 를 만든다. 대상은
   `frontend` deployment, `minReplicas: 2`, `maxReplicas: 8`, 평균 CPU **utilization**
   `60%` 기준으로 스케일한다. 스케일 다운할 때는 안정화 구간(stabilization window) `30` 초를 쓴다.
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

**2) HPA.** `kubectl autoscale` 로 뼈대를 만들 수 있지만 **`behavior` 는 명령형 플래그가 없습니다.**
그래서 `--dry-run=client -o yaml` 로 뽑아 `behavior` 를 붙인 뒤 적용합니다.

```bash
kubectl -n web autoscale deploy frontend --cpu=60% --min=2 --max=8 --name=frontend-hpa \
  --dry-run=client -o yaml > hpa.yaml
# kubectl 1.34 이후 레퍼런스에서는 --cpu-percent 가 빠지고 --cpu(60% 또는 500m)/--memory 로 바뀌었다.
# 더 오래된 kubectl 이면 --cpu-percent=60
vi hpa.yaml        # spec 아래에 behavior 블록 추가
kubectl apply -f hpa.yaml
```

완성된 형태입니다. `type: Resource` 와 `target.type: Utilization` 이 짝이고, `averageUtilization` 은
`target` **안**에 들어갑니다.

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
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
```

**안정화 구간은 스케일 다운의 급한 반응을 막는 장치입니다.** HPA는 주기마다 권장 replica 수를
계산하는데, 스케일 다운할 때는 **지난 구간(기본 300초) 동안의 권장값 중 가장 큰 값**을 씁니다. 부하가
잠깐 꺼졌다고 바로 줄였다가 다시 늘리는 플래핑을 막기 위해서입니다. 30초로 줄이면 부하가 빠진 뒤
더 빨리 줄어듭니다. 스케일 업의 기본 구간은 0초라서 즉시 반응합니다. 줄이는 속도 자체를 제한하려면
`scaleDown.policies`(예: `type: Pods, value: 1, periodSeconds: 60`)를 함께 씁니다.

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
kubectl -n web get hpa frontend-hpa -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}{"\n"}'   # 30
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `Utilization` 은 `requests` 대비 비율이다. `requests.cpu` 가 없으면 HPA는 영원히 `<unknown>` 이다. `behavior`(안정화 구간·정책)는 `kubectl autoscale` 로 못 넣으므로 `--dry-run=client -o yaml` 로 뽑아 추가한다.
- **헷갈리는 지점**: `target.type` 의 세 값이 다릅니다 — `Utilization` 은 request 대비 퍼센트, `AverageValue` 는 파드당 절대값, `Value` 는 전체 합계 절대값. 그리고 `minReplicas: 2` 를 준 HPA는 deployment의 replica가 1이어도 즉시 2로 올립니다. HPA와 `kubectl scale` 을 동시에 쓰면 HPA가 이깁니다.

## 참고 문서

- 검색어: `horizontal pod autoscaling`
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
