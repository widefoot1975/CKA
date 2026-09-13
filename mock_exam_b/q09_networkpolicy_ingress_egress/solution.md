# q09 — Restrict both ingress and egress with NetworkPolicy · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`payments` 네임스페이스에 파드 `api`(label `app=api`, `8080` 리슨)와 `db`(label `app=db`,
`5432` 리슨)가 있다. `frontend` 네임스페이스(label
`kubernetes.io/metadata.name=frontend`)에 파드 `web`(label `app=web`)이, `scanner`
네임스페이스에 파드 `probe`(label `app=web`)가 있다.

파드를 건드리지 않고 `payments` 를 잠근다.

1. `payments` 에 정책 `default-deny-all` 을 만들어 네임스페이스의 모든 파드에 대해 모든 ingress와
   모든 egress를 거부한다.
2. `payments` 에 정책 `api-allow` 를 만들어 `app=api` 로 향하는 TCP `8080` ingress를
   **`frontend` 네임스페이스의** `app=web` 파드에서**만** 허용한다 — `scanner` 의 `probe` 는
   계속 막혀 있어야 한다.
3. 같은 정책에서 `app=api` 가 `payments` 의 `app=db` 로 TCP `5432` 로 나가는 egress를 허용한다.
4. `app=api` 의 DNS 조회를 허용한다(`kube-system` 쪽으로 UDP와 TCP `53`).
5. 확인한다: `web` 은 `api:8080` 에 닿고, `probe` 는 닿지 않으며, `api` 는 `db:5432` 에 닿고,
   `api` 가 `db.payments.svc.cluster.local` 을 해석하고, `api` 가 그 외로는 나가지 못한다.

## 모범 풀이

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: payments
spec:
  podSelector: {}                # 네임스페이스의 모든 파드
  policyTypes: ["Ingress", "Egress"]
```

`policyTypes` 에 이름만 넣고 `ingress`/`egress` 규칙을 아예 쓰지 않으면 전부 거부입니다.
빈 규칙(`ingress: []`)도 같은 뜻이지만 생략이 더 안전합니다.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow
  namespace: payments
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: ["Ingress", "Egress"]
  ingress:
  - from:
    - namespaceSelector:               # 같은 리스트 항목 = AND
        matchLabels:
          kubernetes.io/metadata.name: frontend
      podSelector:
        matchLabels:
          app: web
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: db
    ports:
    - protocol: TCP
      port: 5432
  - to:                                # DNS
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

**`-` 위치가 의미를 완전히 바꿉니다.** 위 ingress에서 `namespaceSelector` 와 `podSelector` 는
`-` 하나를 공유하므로 **AND** 입니다 — "frontend 네임스페이스에 있고 동시에 app=web인 파드".
각자 `-` 를 달면 **OR** 이 되어 "frontend의 모든 파드" 또는 "아무 네임스페이스의 app=web"이
되고, `scanner` 의 `probe` 도 `app=web` 이므로 그대로 통과합니다. 이 문제가 `scanner` 에 같은
라벨의 파드를 둔 이유가 바로 이것입니다.

**egress를 막으면 DNS도 막힙니다.** `api` 가 `db` 의 IP로는 붙는데 이름으로는 안 붙고
`Temporary failure in name resolution` 이 나오면 십중팔구 DNS 규칙 누락입니다. CoreDNS는
`kube-system` 에 있어 `payments` 밖이므로 `podSelector` 만으로는 절대 열리지 않습니다. 그리고
UDP만 열면 응답이 512바이트를 넘어 TCP로 재시도할 때 실패하므로 두 프로토콜을 다 엽니다.

`kubernetes.io/metadata.name` 라벨은 쿠버네티스가 모든 네임스페이스에 자동으로 붙여주므로
라벨을 따로 달 필요가 없습니다.

## 검증

```bash
# 허용 경로
kubectl -n frontend exec web -- curl -s --max-time 3 api.payments:8080   # 응답 있음
kubectl -n payments exec api -- nc -zv db 5432                           # succeeded
kubectl -n payments exec api -- nslookup db.payments.svc.cluster.local   # 해석됨

# 차단 경로
kubectl -n scanner exec probe -- curl -s --max-time 3 api.payments:8080
# curl: (28) Connection timed out  ← 거부는 RST 가 아니라 timeout 으로 보인다
kubectl -n frontend exec web -- curl -s --max-time 3 api.payments:9090   # timeout
kubectl -n payments exec api -- curl -s --max-time 3 https://example.com # timeout

kubectl -n payments describe netpol api-allow    # 규칙이 의도대로 파싱됐는지 확인
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: egress를 deny하면 DNS도 죽는다. `kube-system` 으로 UDP/TCP 53을 명시적으로 열어야 한다.
- **헷갈리는 지점**: `from`/`to` 리스트에서 `-` 를 공유하면 AND, 각각 달면 OR입니다. `namespaceSelector: {}` 는 "모든 네임스페이스"이고 `podSelector: {}` 는 "이 네임스페이스의 모든 파드"인데, 빈 중괄호가 "아무것도 아님"처럼 보여서 반대로 읽기 쉽습니다. NetworkPolicy는 거부를 TCP RST가 아니라 패킷 드롭으로 처리하므로 증상이 `connection refused` 가 아니라 timeout입니다.

## 참고 문서

- 검색어: `network policies`
- https://kubernetes.io/docs/concepts/services-networking/network-policies/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
