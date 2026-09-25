# q09 — Choose the least permissive NetworkPolicy · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `app` 에서 Pod `frontend`(라벨 `app=frontend`, image `busybox:1.36`)는 TCP 포트 `8080` 으로
HTTP 를 서비스하는 Pod `backend`(라벨 `app=backend`)에 닿아야 한다. `app` 에는 기본 차단(default-deny)
ingress NetworkPolicy 가 이미 있어 지금은 이 트래픽을 막고 있다. `/opt/course/f09/` 에 후보 정책 세 개
`policy-a.yaml`, `policy-b.yaml`, `policy-c.yaml` 이 준비되어 있다.

1. `frontend` 가 TCP 포트 `8080` 으로 `backend` 에 닿게 하면서 **가장 적게 허용하는** 후보 하나를 적용한다.
   기존 NetworkPolicy 는 수정하거나 지우지 않는다.
2. 적용한 정책의 파일 이름(예: `policy-x.yaml`)을 `/opt/course/f09/choice.txt` 에 쓴다.
3. 이제 `frontend` 가 포트 `8080` 으로 `backend` 에 연결할 수 있는지 확인한다.

## 모범 풀이

**세 후보 비교** — `cat /opt/course/f09/policy-*.yaml` 로 봅니다. 세 파일은 이름과 `ingress` 부분만
다릅니다.

```yaml
# policy-b.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-b
  namespace: app
spec:
  podSelector:
    matchLabels: {app: backend}       # 세 파일 공통 — 보호 대상은 backend
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels: {app: frontend}  # 같은 네임스페이스의 frontend 만
    ports:
    - {protocol: TCP, port: 8080}
```

```yaml
# policy-a.yaml (allow-backend-a) 의 ingress
  ingress:
  - from:
    - podSelector: {}                 # 같은 네임스페이스의 모든 파드, 포트 제한 없음

# policy-c.yaml (allow-backend-c) 의 ingress
  ingress:
  - from:
    - namespaceSelector: {}           # 모든 네임스페이스의 모든 파드
    ports:
    - {protocol: TCP, port: 8080}
```

| 파일 | 출발지 | 포트 | frontend→8080 | 허용 범위 |
|---|---|---|---|---|
| a | 같은 네임스페이스의 모든 파드 | 전부 | 허용 | 넓음 |
| b | 같은 네임스페이스의 `app=frontend` | TCP 8080 | 허용 | **가장 좁음** |
| c | 모든 네임스페이스의 모든 파드 | TCP 8080 | 허용 | 넓음 |

세 개 모두 조건을 만족하지만, b 가 허용하는 트래픽은 a 와 c 가 허용하는 트래픽의 부분집합입니다.
`from` 에서 `podSelector` 만 쓰면 **정책이 있는 네임스페이스의 파드**, `namespaceSelector: {}` 만 쓰면
**모든 네임스페이스의 모든 파드**를 뜻합니다.

```bash
kubectl apply -f /opt/course/f09/policy-b.yaml
echo policy-b.yaml > /opt/course/f09/choice.txt
```

## 검증

```bash
kubectl -n app get netpol                   # 기존 default-deny + allow-backend-b
BIP=$(kubectl -n app get pod backend -o jsonpath='{.status.podIP}')
kubectl -n app exec frontend -- wget -qO- -T 2 http://$BIP:8080       # 응답 본문이 나오면 성공
kubectl -n app run tmp --rm -it --image=busybox:1.36 --restart=Never -- wget -qO- -T 2 http://$BIP:8080
# wget: download timed out     ← 라벨 없는 파드는 여전히 차단 (a 나 c 였다면 통과했을 것)
cat /opt/course/f09/choice.txt              # policy-b.yaml
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: "least permissive" = 출발지와 포트를 가장 좁게 지정한 정책. `podSelector` 만 = 같은 네임스페이스, `namespaceSelector: {}` = 모든 네임스페이스.
- **헷갈리는 지점**: NetworkPolicy 는 합집합으로 동작합니다. 실수로 a 를 먼저 적용한 뒤 b 를 적용하면 a 의 넓은 허용이 그대로 남으므로, 잘못 적용한 정책은 지워야 합니다. 또 `from` 의 한 항목 안에 `namespaceSelector` 와 `podSelector` 를 함께 쓰면 AND, `-` 로 나눠 두 항목으로 쓰면 OR 입니다.

## 참고 문서

- 검색어: `network policies`
- https://kubernetes.io/docs/concepts/services-networking/network-policies/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
