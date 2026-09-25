# q08 — Move an HTTP Ingress to an HTTPRoute · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `blog` 의 Ingress `blog` 는 호스트 `blog.example.com` 을 공개한다. 경로 `/` 는 Service `blog`
포트 `80` 으로, 경로 `/api` 는 Service `blog-api` 포트 `8080` 으로 간다. 플랫폼 팀은 네임스페이스
`gateway` 에서 Gateway `public-gw` 를 운영한다. 그 listener `http`(protocol HTTP, 포트 80)는 모든
네임스페이스의 route 를 받아들인다. Service `blog` 는 모든 요청에 `blog-web` 으로, Service `blog-api` 는
모든 요청에 `blog-api` 로 응답한다.

1. 네임스페이스 `blog` 에 HTTPRoute `blog` 를 만든다. 네임스페이스 `gateway` 의 Gateway `public-gw` 의
   listener `http` 에 붙이고, Ingress `blog` 와 같은 호스트 이름과 같은 두 경로 규칙을 준다.
2. Gateway `public-gw` 의 주소와 `Host: blog.example.com` 헤더로 `/` 는 `blog` 에, `/api` 는 `blog-api`
   에 도달하는지 확인한다.
3. 확인이 성공한 뒤 Ingress `blog` 를 지운다.

## 모범 풀이

**옮길 내용 확인** — `kubectl -n blog get ingress blog -o yaml` 의 `spec` 입니다.

```yaml
spec:
  ingressClassName: nginx
  rules:
  - host: blog.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: {name: blog, port: {number: 80}}
      - path: /api
        pathType: Prefix
        backend:
          service: {name: blog-api, port: {number: 8080}}
```

| Ingress | HTTPRoute |
|---|---|
| `ingressClassName` (어느 컨트롤러가 처리하나) | `parentRefs` (어느 Gateway 의 어느 listener 에 붙나) |
| `rules[].host` | `hostnames[]` |
| `path` + `pathType: Prefix` | `matches[].path` (`type: PathPrefix`, `value`) |
| `pathType: Exact` | `type: Exact` |
| `backend.service.name` / `port.number` | `backendRefs[].name` / `port` (Service 의 port) |

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: blog
  namespace: blog
spec:
  parentRefs:
  - name: public-gw
    namespace: gateway          # Gateway 가 다른 네임스페이스라 필수
    sectionName: http           # listener 이름
  hostnames:
  - blog.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - {name: blog, port: 80}
  - matches:
    - path: {type: PathPrefix, value: /api}
    backendRefs:
    - {name: blog-api, port: 8080}
```

`kubectl apply -f blog-route.yaml` 로 적용합니다. 규칙 순서는 상관없습니다. Ingress 와 마찬가지로
**가장 긴 prefix 가 이기므로** `/api/...` 는 `blog-api` 로 갑니다. 다른 네임스페이스의 Gateway 에 붙을 수
있는 것은 listener 에 `allowedRoutes.namespaces.from: All` 이 있기 때문입니다. 기본값 `Same` 이었다면
route 가 `Accepted=False` 가 됩니다. backend 는 route 와 같은 네임스페이스에 있으므로 ReferenceGrant 는
필요 없습니다.

## 검증

```bash
kubectl -n blog get httproute blog -o jsonpath='{range .status.parents[0].conditions[*]}{.type}={.status}{"\n"}{end}'
# Accepted=True
# ResolvedRefs=True
GW=$(kubectl -n gateway get gateway public-gw -o jsonpath='{.status.addresses[0].value}')
# 작업 호스트에서 $GW 에 닿지 않으면 임시 busybox:1.36 파드에서 wget -qO- --header 'Host: blog.example.com' 로 확인
curl -s -H 'Host: blog.example.com' http://$GW/            # blog-web
curl -s -H 'Host: blog.example.com' http://$GW/api         # blog-api
curl -s -H 'Host: blog.example.com' http://$GW/api/posts   # blog-api (prefix 매치)

kubectl -n blog delete ingress blog                        # 3) 확인이 끝난 뒤에만
curl -s -H 'Host: blog.example.com' http://$GW/api         # 여전히 blog-api
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Ingress 의 `host` → `hostnames`, `path`+`pathType` → `matches.path`, `backend.service` → `backendRefs`(Service 포트), 컨트롤러 선택 → `parentRefs`(+`namespace`, `sectionName`).
- **헷갈리는 지점**: `PathPrefix: /api` 는 `/api` 와 `/api/...` 에는 맞지만 `/apiv2` 에는 맞지 않습니다(경로 요소 단위 비교). 그리고 새 경로를 확인하기 전에 Ingress 를 먼저 지우면, HTTPRoute 에 실수가 있을 때 서비스가 그대로 끊깁니다.

## 참고 문서

- 검색어: `gateway api`, `migrating from ingress`
- https://kubernetes.io/docs/concepts/services-networking/gateway/
- https://gateway-api.sigs.k8s.io/guides/migrating-from-ingress/
- https://gateway-api.sigs.k8s.io/api-types/httproute/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
