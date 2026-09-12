# q01 — ServiceAccount에 최소 권한 Role 부여

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Cluster Architecture, Installation & Configuration (25%) |
| 배점 | 6 |
| 컨텍스트 | `kubectl config use-context k8s-c1` |
| 목표 시간 | 5분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

`monitoring` 네임스페이스에서 다음을 구성한다.

1. `metrics-reader` 라는 ServiceAccount를 만든다.
2. `pod-reader` 라는 Role을 만든다. 권한은 **`pods`와 `pods/log` 리소스에 대한 `get`, `list`, `watch` 만** 허용한다.
3. 두 리소스를 묶는 RoleBinding `read-pods` 를 만든다.
4. 구성이 올바른지 `kubectl auth can-i` 로 확인한다. `metrics-reader`는 파드를 조회할 수 있어야 하지만 **삭제할 수는 없어야** 한다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 직접 풀고 나서 펼치세요</summary>

```bash
kubectl create namespace monitoring

kubectl -n monitoring create serviceaccount metrics-reader

kubectl -n monitoring create role pod-reader \
  --verb=get,list,watch \
  --resource=pods,pods/log

kubectl -n monitoring create rolebinding read-pods \
  --role=pod-reader \
  --serviceaccount=monitoring:metrics-reader
```

`--serviceaccount` 값은 `<namespace>:<name>` 형식입니다. 네임스페이스를 빼면 `default`로 잡혀 바인딩이 엉뚱한 SA를 가리킵니다.

</details>

## 검증

```bash
kubectl -n monitoring auth can-i get pods \
  --as=system:serviceaccount:monitoring:metrics-reader     # yes

kubectl -n monitoring auth can-i get pods/log \
  --as=system:serviceaccount:monitoring:metrics-reader     # yes

kubectl -n monitoring auth can-i delete pods \
  --as=system:serviceaccount:monitoring:metrics-reader     # no

kubectl -n monitoring auth can-i get pods \
  --as=system:serviceaccount:monitoring:metrics-reader -n default   # no (Role은 네임스페이스 한정)
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Role은 네임스페이스 한정, ClusterRole은 클러스터 전체. 문제가 "이 네임스페이스에서"라고 하면 Role.
- **헷갈리는 지점**: `pods/log`는 별도 리소스(subresource)라 `pods`만 허용하면 로그 조회가 막힙니다.

## 참고 문서

- 검색어: `RBAC`
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
