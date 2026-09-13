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
4. 컨트롤러가 정상 리컨사일하면, 네임스페이스 `default` 에 `spec.schedule: "0 2 * * *"`,
   `spec.target: pvc/data-web-0` 인 `Backup` `nightly` 를 만든다.
5. 컨트롤러가 새 오브젝트를 인지했음을 보인다.

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
```

ClusterRole의 rules에서 `apiGroups: ["telco.io"]` 항목이 빠져 있거나 `verbs` 에 `list`/`watch`
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

**4~5) 커스텀 리소스 생성**

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
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 커스텀 리소스 권한은 `apiGroups` 에 CRD의 그룹을 써야 한다. core 그룹(`""`)이 아니다.
- **헷갈리는 지점**: `kubectl get crd backups.telco.io` 는 **정의**를 보여 주고
  `kubectl get backups` 는 **인스턴스**를 보여 줍니다. CRD가 지워졌는데 `get backups` 가
  "the server doesn't have a resource type" 을 내면 정의 문제, 빈 목록을 내면 인스턴스 문제입니다.
  그리고 CRD를 삭제하면 그 타입의 모든 커스텀 리소스가 함께 삭제됩니다 — 되돌릴 수 없습니다.

## 참고 문서

- 검색어: `custom resources operator pattern`
- https://kubernetes.io/docs/concepts/extend-kubernetes/operator/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
