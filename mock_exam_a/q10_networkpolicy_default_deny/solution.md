# q10 — Default-deny NetworkPolicy with a selective allow · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`prod` 네임스페이스에는 label이 `app=db`, `app=api`, `app=web` 인 파드가 있다.

1. `prod` 네임스페이스의 **모든 파드로 들어오는 트래픽을 전부 차단**하는 NetworkPolicy `default-deny-ingress` 를 만든다.
2. 두 번째 정책 `allow-api-to-db` 를 추가한다. label이 `app=db` 인 파드로 들어오는 트래픽을 label이 `app=api` 인 파드에서 오는 것**만**, 그리고 TCP `5432` 포트**만** 허용한다.
3. `app=api` 파드는 db에 접근되고 `app=web` 파드는 안 되는지 확인한다.

## 모범 풀이

**1) default deny** — `podSelector: {}` 가 "이 네임스페이스의 모든 파드", `policyTypes: [Ingress]` 에 규칙이 하나도 없으면 전부 차단입니다.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: prod
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

**2) 선택 허용**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
  namespace: prod
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api
    ports:
    - protocol: TCP
      port: 5432
```

NetworkPolicy는 **화이트리스트를 더하는 방식**입니다. deny 정책을 "덮어쓰는" 게 아니라, 여러 정책의 허용 범위가 합집합으로 적용됩니다. 그래서 deny를 깔고 필요한 것만 추가하는 순서가 맞습니다.

`from` 의 리스트 문법에 주의하세요. 아래 둘은 의미가 다릅니다.

```yaml
  # (A) api 파드 AND 그 네임스페이스 — 교집합
  - from:
    - podSelector: {matchLabels: {app: api}}
      namespaceSelector: {matchLabels: {env: prod}}

  # (B) api 파드 OR 그 네임스페이스의 아무 파드 — 합집합
  - from:
    - podSelector: {matchLabels: {app: api}}
    - namespaceSelector: {matchLabels: {env: prod}}
```

하이픈 하나 차이로 교집합/합집합이 바뀝니다. 시험에서 자주 감점되는 지점입니다.

## 검증

```bash
kubectl -n prod get networkpolicy
kubectl -n prod describe networkpolicy allow-api-to-db

# api 파드에서 → 통해야 함
kubectl -n prod exec deploy/api -- nc -zv -w 3 db-svc 5432

# web 파드에서 → 막혀야 함 (timeout)
kubectl -n prod exec deploy/web -- nc -zv -w 3 db-svc 5432
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `podSelector: {}` = 모든 파드. `policyTypes` 에 Ingress만 넣으면 egress는 영향 없음.
- **헷갈리는 지점**: `from` 항목 앞 하이픈 위치가 AND/OR를 결정합니다. 그리고 CNI가 NetworkPolicy를 지원해야 실제로 동작합니다 (Flannel 단독은 미지원).

## 참고 문서

- 검색어: `network policies`
- https://kubernetes.io/docs/concepts/services-networking/network-policies/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
