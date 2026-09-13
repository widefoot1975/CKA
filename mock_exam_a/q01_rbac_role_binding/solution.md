# q01 — Namespaced RBAC for a deployment operator · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

배포 자동화 도구가 `staging` 네임스페이스에 제한된 권한으로 접근해야 한다.

1. `staging` 네임스페이스에 ServiceAccount `deploy-bot` 을 만든다.
2. Role `deployment-operator` 를 만들어 다음을 허용한다.
   - `deployments` 에 대한 `get`, `list`, `watch`, `update`, `patch`
   - `deployments/scale` 에 대한 `update`, `patch`
   - `pods` 에 대한 `get`, `list`
3. RoleBinding `deploy-bot-binding` 으로 Role을 ServiceAccount에 연결한다.
4. `deploy-bot` 이 `staging` 의 deployment를 스케일할 수 있지만 **삭제할 수는 없고**, `default` 네임스페이스의 deployment는 **읽을 수 없음**을 확인한다.

## 모범 풀이

```bash
kubectl create namespace staging
kubectl -n staging create serviceaccount deploy-bot
```

Role은 리소스 그룹이 나뉘므로 `--resource` 를 한 번에 주면 동사가 뒤섞입니다. 규칙이 셋이니 yaml이 정확합니다.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-operator
  namespace: staging
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "update", "patch"]
- apiGroups: ["apps"]
  resources: ["deployments/scale"]
  verbs: ["update", "patch"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

```bash
kubectl apply -f role.yaml
kubectl -n staging create rolebinding deploy-bot-binding \
  --role=deployment-operator \
  --serviceaccount=staging:deploy-bot
```

**`apiGroups` 를 맞추는 것이 핵심입니다.** `deployments` 는 `apps` 그룹, `pods` 는 core 그룹(빈 문자열 `""`)입니다. 한 규칙에 몰아넣으면 권한이 엉뚱하게 열리거나 닫힙니다. 그룹이 기억나지 않으면:

```bash
kubectl api-resources | grep -E '^deployments|^pods'
```

`deployments/scale` 은 subresource라 별도 규칙이 필요합니다. `deployments` 만 허용하면 `kubectl scale` 이 거부됩니다.

## 검증

```bash
SA=system:serviceaccount:staging:deploy-bot

kubectl -n staging auth can-i update deployments/scale --as=$SA   # yes
kubectl -n staging auth can-i patch deployments --as=$SA          # yes
kubectl -n staging auth can-i delete deployments --as=$SA         # no
kubectl -n default auth can-i get deployments --as=$SA            # no

# 실제로 스케일해 보기
kubectl -n staging create deploy web --image=nginx
kubectl -n staging scale deploy web --replicas=3 --as=$SA
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `deployments` = `apps` 그룹, `pods` = core(`""`) 그룹. 한 규칙에 섞을 수 없다.
- **헷갈리는 지점**: `scale` 은 subresource(`deployments/scale`)라 따로 열어야 `kubectl scale` 이 동작합니다. Role은 네임스페이스 한정이므로 다른 네임스페이스는 자동으로 막힙니다.

## 참고 문서

- 검색어: `RBAC`
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
