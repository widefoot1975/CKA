# q04 — Install and configure an operator · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

백업 오퍼레이터의 매니페스트 번들이 `/opt/course/q04/operator.yaml` 에 있다. Namespace, CRD,
ServiceAccount, ClusterRole, ClusterRoleBinding, 컨트롤러 Deployment가 들어 있다.

1. 번들을 설치한다. 오퍼레이터는 네임스페이스 `backup-system` 에 있어야 한다.
2. CRD가 등록하는 커스텀 리소스의 전체 리소스 이름, API 그룹, 버전, 짧은 이름, 스코프를 보고한다.
3. 컨트롤러 Deployment `backup-operator` 는 뜨지만 로그에
   `backups.telco.io is forbidden: cannot list resource "backups"` 가 반복된다.
   원인을 찾아 고친다. `cluster-admin` 을 부여하지 않는다.
4. 내장 `view` ClusterRole에 바인딩된 모든 주체가 `backups` 도 읽을 수 있어야 한다. **`view` ClusterRole을
   수정하지 않고** 새 ClusterRole `backup-viewer` 로 달성한다.
5. 컨트롤러가 정상 리컨사일하면, 네임스페이스 `default` 에 `spec.schedule: "0 2 * * *"`,
   `spec.target: pvc/data-web-0` 인 `Backup` `nightly` 를 만들고 컨트롤러가 그것을 인지했음을 보인다.

## 모범 풀이

**1) 설치와 확인**

```bash
kubectl apply -f /opt/course/q04/operator.yaml
kubectl -n backup-system get all,sa
kubectl get crd | grep telco
```

**2) 리소스 메타데이터**

```bash
kubectl api-resources | grep -i backup
# NAME      SHORTNAMES   APIVERSION        NAMESPACED   KIND
# backups   bk           telco.io/v1alpha1 true         Backup

kubectl explain backup --recursive | head -20
kubectl get crd backups.telco.io -o jsonpath='{.spec.scope}{"\n"}'   # Namespaced
```

CRD 오브젝트의 이름은 항상 `<plural>.<group>` 형태입니다 — `backups.telco.io`.
`kubectl api-resources` 가 스코프와 짧은 이름까지 한 줄로 보여 주므로 CRD yaml을 뒤지는 것보다 빠릅니다.

**3) 권한 문제 진단**

```bash
kubectl -n backup-system logs deploy/backup-operator --tail=20
kubectl -n backup-system get deploy backup-operator \
  -o jsonpath='{.spec.template.spec.serviceAccountName}{"\n"}'   # backup-operator

kubectl auth can-i list backups.telco.io -A \
  --as=system:serviceaccount:backup-system:backup-operator       # no

kubectl get clusterrole backup-operator -o yaml
kubectl get clusterrolebinding -o wide | grep backup-operator
# ROLE 이 ClusterRole/backup-operator 이고 SERVICEACCOUNTS 가 backup-system/backup-operator 인지
```

권한 문제는 두 곳 중 하나입니다. **바인딩**의 subject가 틀렸거나(네임스페이스를 `default` 로 적는 실수가
흔함), **ClusterRole** 의 규칙이 모자랍니다. 이 문제에서는 바인딩은 맞고, ClusterRole의 rules에서 `apiGroups: ["telco.io"]` 항목이 빠져 있거나 `verbs` 에 `list`/`watch`
가 없습니다. 커스텀 리소스는 core 그룹이 아니므로 `apiGroups: [""]` 로는 절대 잡히지 않습니다.
또 컨트롤러는 리컨사일 루프를 위해 `list` 와 `watch` 가 동시에 필요하고, 상태를 쓰려면
`backups/status` 서브리소스 권한이 따로 필요합니다.

```bash
kubectl patch clusterrole backup-operator --type=json -p='[
  {"op":"add","path":"/rules/-","value":{
    "apiGroups":["telco.io"],
    "resources":["backups","backups/status","backups/finalizers"],
    "verbs":["get","list","watch","create","update","patch","delete"]}}
]'

kubectl -n backup-system rollout restart deploy/backup-operator
```

ClusterRole을 고쳤으면 파드를 재시작할 필요는 원칙적으로 없습니다(RBAC은 요청 시점에 평가).
다만 컨트롤러가 시작 시 한 번만 informer를 세우고 실패한 채로 백오프 중인 경우가 많아
`rollout restart` 가 확실합니다.

**4) `view` 를 고치지 않고 넓히기 — ClusterRole 집계(aggregation)**

내장 `view`, `edit`, `admin` 은 **집계 ClusterRole** 입니다. 자기 rules를 직접 들고 있는 것이 아니라
`aggregationRule` 의 라벨 셀렉터에 걸리는 ClusterRole들의 rules를 컨트롤러가 모아서 채웁니다. 그래서
`rbac.authorization.k8s.io/aggregate-to-view: "true"` 라벨을 단 ClusterRole을 하나 만들면 그 권한이
`view` 안으로 흘러 들어갑니다. operator가 흔히 `*-viewer`/`*-editor` 롤을 이렇게 배포합니다.

```yaml
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
kubectl apply -f backup-viewer.yaml
kubectl get clusterrole view -o yaml | grep -B2 -A3 backups     # 몇 초 안에 view 에 나타난다
```

`view` 를 직접 편집하면 안 되는 이유는 그 `rules` 가 **집계 컨트롤러 소유**이기 때문입니다. 손으로 넣은
규칙은 다음 동기화에서 바로 덮어써집니다. 같은 원리로 직접 만든 집계 ClusterRole에도 `rules` 를 손으로
쓰지 않습니다(`aggregationRule` + `rules: []`). 라벨은 **집계당할 쪽**(`backup-viewer`)에 달고, 셀렉터는
**집계하는 쪽**에 있습니다. 방향을 뒤집으면 rules가 영원히 비어 있습니다.

**5) 커스텀 리소스 생성**

```yaml
# nightly.yaml
apiVersion: telco.io/v1alpha1
kind: Backup
metadata:
  name: nightly
  namespace: default
spec:
  schedule: "0 2 * * *"
  target: pvc/data-web-0
```

```bash
kubectl apply -f nightly.yaml
```

## 검증

```bash
kubectl -n backup-system get pods          # backup-operator  1/1 Running, RESTARTS 안 늘어남
kubectl -n backup-system logs deploy/backup-operator --tail=20 | grep -i forbidden   # 결과 없음

kubectl get backups                        # NAME=nightly
kubectl get bk nightly -o yaml             # 짧은 이름으로도 조회된다
kubectl describe backup nightly            # Events 또는 status에 컨트롤러 기록

kubectl -n backup-system logs deploy/backup-operator | grep nightly
# "Reconciling Backup default/nightly" 류의 줄

# view 에 묶인 주체가 backups 를 읽을 수 있는지
kubectl create serviceaccount viewer-test -n default
kubectl create rolebinding viewer-test --clusterrole=view --serviceaccount=default:viewer-test -n default
kubectl auth can-i list backups.telco.io -n default --as=system:serviceaccount:default:viewer-test   # yes
kubectl auth can-i delete backups.telco.io -n default --as=system:serviceaccount:default:viewer-test # no
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 커스텀 리소스 권한은 `apiGroups` 에 CRD의 그룹을 써야 한다. core 그룹(`""`)이 아니다. 권한 오류는 ClusterRole의 규칙과 ClusterRoleBinding의 subject를 둘 다 본다. 내장 `view`/`edit`/`admin` 을 넓힐 때는 `aggregate-to-view` 등의 라벨을 단 새 ClusterRole을 만든다.
- **헷갈리는 지점**: `kubectl get crd backups.telco.io` 는 **정의**를 보여 주고
  `kubectl get backups` 는 **인스턴스**를 보여 줍니다. CRD가 지워졌는데 `get backups` 가
  "the server doesn't have a resource type" 을 내면 정의 문제, 빈 목록을 내면 인스턴스 문제입니다.
  그리고 CRD를 삭제하면 그 타입의 모든 커스텀 리소스가 함께 삭제됩니다 — 되돌릴 수 없습니다.

## 참고 문서

- 검색어: `custom resources operator pattern`
- https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
