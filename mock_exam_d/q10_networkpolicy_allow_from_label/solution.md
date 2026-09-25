# q10 — Allow traffic to a backend from one frontend only · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`proj` 네임스페이스에 파드 세 개가 있다. `backend`(라벨 `app=backend`, 포트 `8080` 에서 HTTP 서비스),
`frontend`(라벨 `app=frontend`), `other`(라벨 `app=other`). `frontend` 와 `other` 는 `busybox:1.36` 으로
돈다. NetworkPolicy `deny-all` 이 이미 네임스페이스의 모든 인그레스 트래픽을 막고 있다.

1. `proj` 에 라벨 `app=backend` 파드에 적용되는 NetworkPolicy `allow-frontend` 를 만든다.
2. 이 정책은 같은 네임스페이스의 `app=frontend` 파드에서 오는 TCP `8080` 인그레스**만** 허용해야 한다.
   `deny-all` 은 고치거나 지우지 않는다.
3. `frontend` 에서 `backend` 의 8080으로 접속이 되고, `other` 에서 보낸 같은 요청은 타임아웃되는지 확인한다.

## 모범 풀이

```bash
kubectl -n proj get pods --show-labels
kubectl -n proj get netpol deny-all -o yaml      # podSelector: {} + policyTypes: [Ingress], 규칙 없음
```

```yaml
# allow-frontend.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: proj
spec:
  podSelector:
    matchLabels:
      app: backend                # 이 정책이 보호하는 파드
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:                # namespaceSelector 없이 쓰면 같은 네임스페이스만
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

```bash
kubectl apply -f allow-frontend.yaml
```

**NetworkPolicy는 더하기만 합니다 — 이 문제의 핵심입니다.** 정책 사이에 순서나 우선순위가 없고 "거부"
규칙도 없습니다. 어떤 정책이든 파드를 선택하면 그 파드는 격리되고, 그 파드를 선택한 **모든 정책의 허용
규칙의 합집합**만 통과합니다. `deny-all` 은 모든 파드를 선택하되 허용 규칙이 0개이고, `allow-frontend`
가 backend에 규칙 하나를 더합니다. 결과는 "frontend → backend:8080 만 허용"입니다. 그래서 `deny-all` 을
건드릴 필요가 없습니다.

## 검증

```bash
kubectl -n proj get netpol
# NAME             POD-SELECTOR   AGE
# allow-frontend   app=backend    10s
# deny-all         <none>         1h

BIP=$(kubectl -n proj get pod backend -o jsonpath='{.status.podIP}')
kubectl -n proj exec frontend -- wget -qO- -T 3 http://$BIP:8080 | head -3   # 응답 본문이 나온다
kubectl -n proj exec other -- wget -qO- -T 3 http://$BIP:8080
# wget: download timed out
# command terminated with exit code 1
```

거부된 요청은 거절(connection refused)이 아니라 **패킷이 버려져 타임아웃**됩니다. `-T 3` 으로 기다리는
시간을 줄여 둡니다.

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 정책은 합집합이다. default deny 위에 필요한 허용만 새 정책으로 더한다.
- **헷갈리는 지점**: `from` 아래 한 항목에 `namespaceSelector` 와 `podSelector` 를 같이 쓰면 AND(그 네임스페이스의 그 파드), `-` 로 두 항목으로 나누면 OR(그 네임스페이스 전체 **또는** 이 네임스페이스의 그 파드)입니다. 들여쓰기 한 칸이 허용 범위를 바꿉니다. 그리고 NetworkPolicy는 CNI가 구현합니다(Calico, Cilium 등). 지원하지 않는 CNI에서는 정책을 만들어도 아무 효과가 없습니다.

## 참고 문서

- 검색어: `network policies`
- https://kubernetes.io/docs/concepts/services-networking/network-policies/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
