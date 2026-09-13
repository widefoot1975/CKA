# q05 — Self-healing with StatefulSet and DaemonSet · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `infra` 에서:

1. `busybox:1.36` 을 `sh -c 'while true; do sleep 30; done'` 명령으로 실행하는 DaemonSet
   `node-agent` 를 만든다. 컨트롤 플레인 노드를 포함해 **모든** 노드에서 실행되어야 한다.
2. `redis:7.2` 3 레플리카의 StatefulSet `cache` 를 만든다. 기존 헤드리스 Service `cache` 가
   관리하고, 컨테이너 포트는 6379다.
3. 파드 `cache-1` 을 삭제하고 컨트롤러가 무엇을 재생성하는지 기록한다 — 파드 이름과 서수가
   유지되는지 여부.
4. 워커 노드 하나의 `node-agent` 파드를 삭제하고 얼마나 빨리 돌아오는지 기록한다.
5. DaemonSet 컨트롤러가 무엇을 기준으로 리컨사일하는지, StatefulSet이 Deployment와 달리
   무엇을 보장하는지 각각 한 줄로 적는다.

## 모범 풀이

```yaml
# q05.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-agent
  namespace: infra
spec:
  selector:
    matchLabels:
      app: node-agent
  template:
    metadata:
      labels:
        app: node-agent
    spec:
      tolerations:                       # 컨트롤 플레인에 뜨게 하려면 필수
        - key: node-role.kubernetes.io/control-plane
          operator: Exists
          effect: NoSchedule
      containers:
        - name: agent
          image: busybox:1.36
          command: ["sh", "-c", "while true; do sleep 30; done"]
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cache
  namespace: infra
spec:
  serviceName: cache                     # 헤드리스 서비스 이름. 빠뜨리면 DNS가 안 생긴다
  replicas: 3
  selector:
    matchLabels:
      app: cache
  template:
    metadata:
      labels:
        app: cache
    spec:
      containers:
        - name: redis
          image: redis:7.2
          ports:
            - containerPort: 6379
```

```bash
kubectl apply -f q05.yaml
kubectl -n infra delete pod cache-1
kubectl -n infra get pods -w
```

`cache-1` 은 **정확히 같은 이름 `cache-1` 로** 돌아옵니다. StatefulSet 파드 이름은
`<sts>-<ordinal>` 로 고정이고, 같은 서수의 PVC와 DNS 레코드를 다시 잡습니다. Deployment라면
`web-7d9f-xk2mq` 같은 새 무작위 이름이 나옵니다. 그리고 삭제한 서수 하나만 재생성되고
`cache-0`, `cache-2` 는 건드리지 않습니다.

DaemonSet 파드는 삭제 후 보통 몇 초 안에 돌아옵니다. DaemonSet 컨트롤러는 레플리카 수가 아니라
**노드 목록**을 기준으로 리컨사일합니다 — 셀렉터와 톨러레이션을 통과하는 모든 노드에 파드가
정확히 하나 있는 상태를 맞춥니다. 그래서 노드를 추가하면 자동으로 파드가 생기고, `replicas`
필드 자체가 없습니다.

컨트롤 플레인 톨러레이션이 이 문제의 실제 함정입니다. 톨러레이션 없이 만들면 워커에만 뜨는데,
`kubectl get ds` 의 DESIRED 칼럼도 워커 수에 맞춰 나오므로 겉보기에 정상으로 보입니다.
노드 수와 대조해야 발견됩니다.

## 검증

```bash
kubectl get nodes --no-headers | wc -l           # 예: 3
kubectl -n infra get ds node-agent
# DESIRED CURRENT READY = 3  (노드 수와 같아야 한다)
kubectl -n infra get pods -o wide -l app=node-agent    # 각 노드에 1개씩

kubectl -n infra get pods -l app=cache
# cache-0, cache-1, cache-2  전부 Running

kubectl -n infra delete pod cache-1
kubectl -n infra get pods -l app=cache -w        # 다시 cache-1 로 생성됨

kubectl -n infra get sts cache \
  -o jsonpath='{.spec.serviceName}{"\n"}'        # cache
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: DaemonSet이 모든 노드에 떠야 한다면 control-plane 테인트 톨러레이션을 반드시 넣는다.
- **헷갈리는 지점**: `kubectl create daemonset` 서브커맨드는 없습니다. Deployment yaml을 만들어
  (`kubectl create deploy x --image=... --dry-run=client -o yaml`) `kind` 를 DaemonSet으로 바꾸고
  `replicas`, `strategy` 를 지우는 것이 가장 빠릅니다. StatefulSet도 마찬가지로 생성 서브커맨드가
  없고, `serviceName` 은 StatefulSet에만 있는 필수 필드입니다.

## 참고 문서

- 검색어: `daemonset`
- https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
- https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
