# q03 — Cluster-wide permissions with ClusterRole aggregation · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

모니터링 에이전트에 읽기 권한이 필요하다. 나중에 바인딩된 롤을 수정하지 않고 기능을 추가할 수
있도록, 여러 개의 작은 권한 묶음을 조립해서 구성한다.

1. ClusterRole `monitoring-aggregate` 를 만든다. **자체 rules를 갖지 않아야 하고**
   `rbac.telco.io/aggregate-to-monitoring: "true"` 레이블이 붙은 모든 ClusterRole을 집계해야 한다.
2. 그 레이블을 가진 ClusterRole `monitoring-pods` 를 만든다. core API 그룹의 `pods` 와
   `pods/log` 에 `get`, `list`, `watch` 를 부여한다.
3. 그 레이블을 가진 ClusterRole `monitoring-nodes` 를 만든다. `nodes` 와 `nodes/metrics` 에
   `get`, `list` 를 부여한다.
4. 네임스페이스 `monitoring` 과 그 안의 ServiceAccount `agent` 를 만들고,
   `monitoring-aggregate` 를 그 ServiceAccount에 클러스터 범위로 바인딩한다.
5. 별도로, 내장 `view` 롤의 주체들이 `backups.telco.io` 커스텀 리소스를 읽을 수 있어야 한다.
   **`view` ClusterRole을 수정하지 않고** `backup-viewer` 라는 새 ClusterRole로 달성한다.
6. 이 ServiceAccount가 `kube-system` 의 파드를 list할 수 있으나 delete는 못 하는 것을 증명한다.

## 모범 풀이

```yaml
# q03.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-aggregate
aggregationRule:
  clusterRoleSelectors:
    - matchLabels:
        rbac.telco.io/aggregate-to-monitoring: "true"
rules: []          # 비워 둔다. 컨트롤러가 채운다
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-pods
  labels:
    rbac.telco.io/aggregate-to-monitoring: "true"
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-nodes
  labels:
    rbac.telco.io/aggregate-to-monitoring: "true"
rules:
  - apiGroups: [""]
    resources: ["nodes", "nodes/metrics"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: backup-viewer
  labels:
    rbac.authorization.k8s.io/aggregate-to-view: "true"
rules:
  - apiGroups: ["telco.io"]
    resources: ["backups"]
    verbs: ["get", "list", "watch"]
```

```bash
kubectl create namespace monitoring
kubectl -n monitoring create serviceaccount agent
kubectl apply -f q03.yaml
kubectl create clusterrolebinding monitoring-agent \
  --clusterrole=monitoring-aggregate \
  --serviceaccount=monitoring:agent
```

핵심은 **집계 ClusterRole의 `rules` 를 직접 쓰지 않는다**는 것입니다. `aggregationRule` 이
있으면 controller-manager의 ClusterRole aggregation 컨트롤러가 셀렉터에 걸린 롤들의 rules를
합쳐 `rules` 필드에 덮어씁니다. 손으로 쓴 rules는 다음 동기화에서 사라집니다. 그래서 `rules: []`
로 두거나 필드 자체를 생략합니다.

`rbac.authorization.k8s.io/aggregate-to-view: "true"` 는 내장 `view` 가 이미 갖고 있는
`aggregationRule` 의 셀렉터입니다. 즉 내장 `view`, `edit`, `admin` 은 전부 집계 롤이고,
레이블만 붙인 새 ClusterRole을 만들면 그 안으로 권한이 흘러 들어갑니다. `view` 를 직접 편집하면
다음 업그레이드 때 kube-apiserver의 부트스트랩 정책 조정(reconcile)이 원복시켜 버립니다.

## 검증

```bash
kubectl get clusterrole monitoring-aggregate -o yaml | grep -A15 '^rules:'
# pods, pods/log, nodes, nodes/metrics 가 컨트롤러에 의해 채워져 있어야 한다

kubectl auth can-i list pods -n kube-system \
  --as=system:serviceaccount:monitoring:agent          # yes
kubectl auth can-i delete pods -n kube-system \
  --as=system:serviceaccount:monitoring:agent          # no
kubectl auth can-i get nodes \
  --as=system:serviceaccount:monitoring:agent          # yes

kubectl get clusterrole view -o jsonpath='{.rules}' | tr ',' '\n' | grep backups
# backups 가 view 안에 나타난다
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `aggregationRule` 이 있는 ClusterRole의 `rules` 는 컨트롤러 소유다. 절대 직접 쓰지 않는다.
- **헷갈리는 지점**: 집계는 **ClusterRole → ClusterRole** 방향으로만 동작합니다. Role(네임스페이스
  범위)은 집계에 참여할 수 없습니다. 그리고 레이블은 집계당할 쪽(`monitoring-pods`)에 붙이고,
  셀렉터는 집계하는 쪽(`monitoring-aggregate`)에 씁니다 — 방향을 뒤집으면 rules가 영원히 비어 있습니다.

## 참고 문서

- 검색어: `aggregated ClusterRoles`
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
