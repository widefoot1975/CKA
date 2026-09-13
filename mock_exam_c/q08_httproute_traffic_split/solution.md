# q08 — Weighted traffic splitting with HTTPRoute · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

Gateway API CRD가 설치되어 있고, 네임스페이스 `gateway-system` 에 Gateway `web-gw` 가 있다.
포트 80에 `http` 라는 HTTP 리스너가 있고 모든 네임스페이스의 라우트를 허용한다.

네임스페이스 `shop` 에서:

1. Gateway API가 사용 가능한지 확인하고 `HTTPRoute` 리소스의 API 그룹과 버전을 보고한다.
2. Deployment `shop-v1`, `shop-v2` 는 이미 있다. ClusterIP Service `shop-v1`, `shop-v2` 를
   만든다. 포트 80, 타깃 컨테이너 포트 80.
3. `web-gw` 에 연결된 HTTPRoute `shop-route` 를 만든다. 호스트네임 `shop.example.com`,
   경로 prefix `/` 매칭, 요청의 90%를 `shop-v1`, 10%를 `shop-v2` 로 보낸다.
4. 경로 prefix `/canary` 에 두 번째 규칙을 추가한다. 위의 가중치와 무관하게 **모든** 트래픽을
   `shop-v2` 로 보낸다.
5. 라우트가 Gateway에 수락되었고 부모 참조가 해결되었음을 확인한다.
6. `weight` 의 숫자가 실제로 무엇을 의미하는지 한 줄로 적는다.

## 모범 풀이

**1) 가용성 확인**

```bash
kubectl get crd | grep gateway.networking.k8s.io
kubectl api-resources | grep -i httproute
# httproutes   gateway.networking.k8s.io/v1   true   HTTPRoute
kubectl -n gateway-system get gateway web-gw
```

**2) 서비스**

```bash
kubectl -n shop expose deploy shop-v1 --name=shop-v1 --port=80 --target-port=80
kubectl -n shop expose deploy shop-v2 --name=shop-v2 --port=80 --target-port=80
```

**3~4) HTTPRoute**

```yaml
# shop-route.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: shop-route
  namespace: shop
spec:
  parentRefs:
    - name: web-gw
      namespace: gateway-system      # Gateway가 다른 네임스페이스면 반드시 명시
      sectionName: http              # 리스너 이름
  hostnames:
    - shop.example.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /canary           # 더 구체적인 경로를 먼저 쓰는 편이 읽기 쉽다
      backendRefs:
        - name: shop-v2
          port: 80
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: shop-v1
          port: 80
          weight: 90
        - name: shop-v2
          port: 80
          weight: 10
```

```bash
kubectl apply -f shop-route.yaml
```

**`weight` 는 백분율이 아니라 상대 비율입니다.** 각 백엔드가 받는 몫은
`자기 weight ÷ 같은 규칙 내 weight 합` 입니다. 90/10은 합이 100이라 우연히 퍼센트처럼 보이지만
9/1로 써도 결과가 같습니다. weight를 생략하면 기본값 1입니다 — 그래서 한쪽에만 weight를 쓰면
(`shop-v1: 90` 만) 실제 비율이 90:1이 되어 의도와 크게 달라집니다. 양쪽 다 쓰거나 양쪽 다 빼야 합니다.

규칙 순서는 매칭 우선순위를 결정하지 않습니다. Gateway API는 **더 긴 경로 prefix를 먼저** 매칭하는
규격이 정해져 있어서, `/canary` 요청은 yaml 순서와 무관하게 `/canary` 규칙으로 갑니다.
Ingress와 달리 이것이 구현체 재량이 아니라 스펙에 명시된 동작입니다.

## 검증

```bash
kubectl -n shop get httproute shop-route
# HOSTNAMES 에 ["shop.example.com"]

kubectl -n shop describe httproute shop-route
# Parents:
#   Conditions:
#     Type: Accepted        Status: True
#     Type: ResolvedRefs    Status: True

kubectl -n shop get httproute shop-route \
  -o jsonpath='{.status.parents[0].conditions[*].type}:{.status.parents[0].conditions[*].status}{"\n"}'

kubectl -n gateway-system get gateway web-gw
# PROGRAMMED True, ADDRESS 에 IP

GW=$(kubectl -n gateway-system get gateway web-gw -o jsonpath='{.status.addresses[0].value}')
for i in $(seq 1 20); do curl -s -H "Host: shop.example.com" http://$GW/; done | sort | uniq -c
# v1 약 18회, v2 약 2회
curl -s -H "Host: shop.example.com" http://$GW/canary/     # 항상 v2
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `weight` 는 상대값이고 생략 시 기본 1이다. 한쪽만 쓰면 비율이 망가진다.
- **헷갈리는 지점**: `ResolvedRefs: False` 는 거의 항상 `backendRefs` 의 서비스 이름이나
  포트가 틀린 것입니다. `Accepted: False` 는 `parentRefs` 문제(Gateway 이름·네임스페이스 오타,
  또는 Gateway의 `allowedRoutes` 가 이 네임스페이스를 허용하지 않음)입니다. 두 컨디션을 구분해서
  보면 어디를 고칠지 바로 나옵니다.

## 참고 문서

- 검색어: `gateway api HTTPRoute traffic splitting`
- https://kubernetes.io/docs/concepts/services-networking/gateway/
- https://gateway-api.sigs.k8s.io/guides/traffic-splitting/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
