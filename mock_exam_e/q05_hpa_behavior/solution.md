# q05 — Autoscale a Deployment with an HPA · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`autoscale` 네임스페이스의 Deployment `apache-web` 은 `httpd:2.4` 를 실행하고, 컨테이너에는 이미
CPU request `100m` 가 있다. metrics-server는 설치되어 있다.

1. `autoscale` 네임스페이스에 API 버전 `autoscaling/v2` 로 HorizontalPodAutoscaler `apache-web` 을
   만든다. 대상은 Deployment `apache-web` 이고 `minReplicas: 1`, `maxReplicas: 4`, 목표 평균 CPU
   사용률(utilization) `50%` 이다.
2. 스케일 다운할 때 HPA는 안정화 구간(stabilization window) `30` 초를 사용해야 한다.
3. HPA가 `<unknown>` 이 아닌 실제 CPU 퍼센트를 보고하는지 확인한다.

## 모범 풀이

**뼈대는 명령으로, `behavior` 는 yaml로.** `kubectl autoscale` 에는 `behavior` 를 넣는 플래그가
없습니다. `--dry-run=client -o yaml` 로 뽑아 블록 하나를 추가한 뒤 적용합니다.

```bash
kubectl -n autoscale autoscale deploy apache-web --name=apache-web \
  --min=1 --max=4 --cpu=50% --dry-run=client -o yaml > hpa.yaml
# kubectl 1.34 이후 레퍼런스는 --cpu=50% 이고, 예전 --cpu-percent=50 은 deprecated
vi hpa.yaml            # spec 아래에 behavior 추가
kubectl apply -f hpa.yaml
```

완성본입니다. 출력의 `apiVersion` 이 `autoscaling/v2` 인지 확인합니다. 구버전 kubectl이
`autoscaling/v1`(`targetCPUUtilizationPercentage`)으로 내면 이 형태로 고쳐 씁니다 — `behavior` 는
v2에만 있습니다.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: apache-web
  namespace: autoscale
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: apache-web
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:                          # ← 직접 추가한 부분
    scaleDown:
      stabilizationWindowSeconds: 30
```

**안정화 구간** — HPA는 약 15초마다 권장 replica 수를 계산합니다. 스케일 다운할 때는 **최근 구간
안의 권장값 중 가장 큰 값**을 쓰기 때문에, 부하가 잠깐 줄었다고 바로 줄였다가 다시 늘리는 플래핑이
없어집니다. 기본값은 스케일 다운 300초, 스케일 업 0초입니다. 30초로 줄이면 부하가 빠진 뒤 훨씬 빨리
줄어듭니다.

`Utilization` 은 실제 사용량을 컨테이너의 `requests.cpu` 로 나눈 비율입니다. request `100m` 가 이미
있으므로 파드 평균 사용량이 `50m` 을 넘으면 늘어납니다. request가 없거나 metrics-server가 없으면
`TARGETS` 가 `<unknown>` 에 머뭅니다.

## 검증

```bash
kubectl -n autoscale get hpa apache-web
# NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
# apache-web   Deployment/apache-web   cpu: 1%/50%   1         4         1          45s
# 만든 직후 15~30초는 <unknown> 일 수 있다 — 잠시 뒤 다시 본다
kubectl -n autoscale get hpa apache-web \
  -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}{"\n"}'     # 30
kubectl -n autoscale describe hpa apache-web | grep -A4 Conditions
# ScalingActive   True   ValidMetricFound
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `behavior` 는 플래그가 없다 → `kubectl autoscale ... --dry-run=client -o yaml` 로 뽑아 `spec.behavior.scaleDown.stabilizationWindowSeconds` 를 추가한다.
- **헷갈리는 지점**: `averageUtilization` 은 `target` **안**에 들어가고 `type: Utilization` 과 짝입니다. 안정화 구간은 "줄이기 전에 기다리는 타이머"가 아니라 "구간 안의 가장 높은 권장값을 택하는 규칙"이라, 그 사이 부하가 다시 오르면 줄지 않습니다.

## 참고 문서

- 검색어: `horizontal pod autoscaling`
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
