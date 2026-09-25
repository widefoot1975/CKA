# q02 — Read-only pod access for a ServiceAccount · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`apps` 네임스페이스의 모니터링 도구가 자기 ServiceAccount로 돌게 된다. 이 도구는 파드와 파드 로그를
읽을 수만 있어야 하고 그 밖의 권한은 없어야 한다.

1. `apps` 네임스페이스에 ServiceAccount `monitor` 를 만든다.
2. `apps` 에 Role `pod-reader` 를 만든다. 리소스 `pods` 와 `pods/log` 에 동사 `get`, `list`, `watch` 를
   허용한다.
3. `apps` 에 RoleBinding `monitor-pod-reader` 를 만들어 이 Role을 ServiceAccount에 연결한다.
4. ServiceAccount를 흉내 내어(impersonate) `kubectl auth can-i` 로, `apps` 에서 파드 목록 조회와 파드
   로그 읽기는 되고 파드 삭제는 안 되는지 확인한다.

## 모범 풀이

```bash
kubectl -n apps create serviceaccount monitor
kubectl -n apps create role pod-reader --verb=get,list,watch --resource=pods,pods/log
kubectl -n apps create rolebinding monitor-pod-reader \
  --role=pod-reader --serviceaccount=apps:monitor
```

`--serviceaccount` 는 `<네임스페이스>:<이름>` 형식이어야 합니다(`monitor` 만 쓰면 에러). 만들어진 Role의
규칙은 다음과 같습니다.

```yaml
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]
```

**`pods/log` 는 `pods` 와 별개인 서브리소스입니다.** `kubectl logs` 는 파드 오브젝트 조회와 별도로
`GET .../pods/<이름>/log` 를 호출하고, RBAC은 서브리소스를 `<리소스>/<서브리소스>` 로 따로 허가합니다.
`pods` 만 허용하면 파드 목록은 보여도 로그는 `Forbidden` 입니다. `pods/exec`, `deployments/scale` 도
같은 원리입니다.

**검증은 `--as` 로 합니다.** ServiceAccount의 사용자 이름은 `system:serviceaccount:<네임스페이스>:<이름>`
입니다. 서브리소스는 반드시 `--subresource` 로 묻습니다.

```bash
SA=system:serviceaccount:apps:monitor
kubectl auth can-i list pods -n apps --as=$SA                      # yes
kubectl auth can-i get pods --subresource=log -n apps --as=$SA     # yes
kubectl auth can-i delete pods -n apps --as=$SA                    # no
```

`kubectl auth can-i get pods/log` 처럼 쓰면 kubectl은 **`log` 를 파드 이름으로 해석**해 "이름이 `log` 인
파드를 get할 수 있는가"를 묻습니다. `get pods` 만 있어도 `yes` 가 나오므로, `pods/log` 규칙을 빠뜨린
실수를 잡아내지 못합니다.

## 검증

```bash
kubectl -n apps describe rolebinding monitor-pod-reader
# Role:      Kind: Role,  Name: pod-reader
# Subjects:  ServiceAccount  monitor  apps
kubectl auth can-i --list -n apps --as=system:serviceaccount:apps:monitor | grep pods
# pods/log   []   []   [get list watch]
# pods       []   []   [get list watch]
kubectl auth can-i list pods -n default --as=system:serviceaccount:apps:monitor   # no — Role은 apps 안에서만 유효
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 로그 읽기 권한은 `pods/log` 이고, 검증은 `kubectl auth can-i get pods --subresource=log --as=system:serviceaccount:<ns>:<sa>` 로 한다.
- **헷갈리는 지점**: Role/RoleBinding은 네임스페이스 범위, ClusterRole/ClusterRoleBinding은 클러스터 범위입니다. ClusterRole을 RoleBinding으로 묶으면 그 RoleBinding의 네임스페이스 안에서만 권한이 생깁니다. `--as` 는 흉내일 뿐이므로, 실제 토큰으로 확인하려면 `kubectl create token monitor -n apps` 로 받은 토큰을 `--token` 으로 넘깁니다.

## 참고 문서

- 검색어: `rbac`, `checking api access`
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#referring-to-resources
- https://kubernetes.io/docs/reference/access-authn-authz/authorization/#checking-api-access

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
