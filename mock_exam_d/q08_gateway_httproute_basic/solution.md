# q08 — Expose a Service through the Gateway API · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

GatewayClass `nginx` 가 설치되어 있고 `Accepted` 상태다. 네임스페이스 `web` 에 Deployment `frontend` 와
Service `frontend`(포트 80)가 있다.

1. `web` 에 gatewayClassName `nginx` 인 Gateway `web-gw` 를 만든다. listener는 하나이고 이름 `http`,
   protocol `HTTP`, port `80` 이다.
2. `web` 에 `web-gw` 의 `http` listener에 붙는 HTTPRoute `frontend-route` 를 만든다. hostname
   `shop.example.com` 에 대해 path prefix `/` 를 Service `frontend` 포트 80으로 보낸다.
3. Gateway가 `Programmed` 인지, route가 `Accepted=True` 와 `ResolvedRefs=True` 를 보고하는지, 그리고
   Gateway 주소로 host `shop.example.com` 을 넣어 보낸 HTTP 요청이 frontend 페이지를 돌려주는지 확인한다.

## 모범 풀이

```yaml
# web-gw.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gw
  namespace: web
spec:
  gatewayClassName: nginx
  listeners:
  - name: http                    # HTTPRoute 의 sectionName 이 이 이름을 가리킨다
    protocol: HTTP
    port: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: web
spec:
  parentRefs:
  - name: web-gw
    sectionName: http
  hostnames:
  - shop.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - name: frontend
      port: 80                    # Service 의 port (targetPort 가 아님)
```

```bash
kubectl apply -f web-gw.yaml
```

**Gateway는 "입구", HTTPRoute는 "경로"입니다.** Gateway가 어떤 포트·프로토콜로 받을지(listener)를
정하고, HTTPRoute는 `parentRefs` 로 그 입구에 붙어 호스트·경로별로 어느 Service로 보낼지를 정합니다.
`sectionName` 은 Gateway 안의 listener 이름입니다. listener의 `allowedRoutes.namespaces.from` 기본값이
`Same` 이라, 같은 네임스페이스(`web`)의 route는 추가 설정 없이 붙습니다. 붙지 않으면 route의 reason을 봅니다.

| route 상태 (reason) | 흔한 원인 |
|---|---|
| `Accepted=False`, `NoMatchingParent` | `parentRefs` 의 Gateway 이름이나 `sectionName` 오타 |
| `Accepted=False`, `NotAllowedByListeners` | route가 다른 네임스페이스에 있음 (listener 기본값 `Same`) |
| `ResolvedRefs=False`, `BackendNotFound` | `backendRefs` 의 Service 이름 오류 — 요청은 HTTP 500 |

## 검증

```bash
kubectl get gatewayclass nginx            # ACCEPTED True — 전제
kubectl -n web get gateway web-gw
# NAME     CLASS   ADDRESS         PROGRAMMED   AGE
# web-gw   nginx   192.168.100.50  True         30s
kubectl -n web get httproute frontend-route -o jsonpath=\
'{range .status.parents[0].conditions[*]}{.type}={.status} ({.reason}){"\n"}{end}'
# Accepted=True (Accepted)
# ResolvedRefs=True (ResolvedRefs)

GW=$(kubectl -n web get gateway web-gw -o jsonpath='{.status.addresses[0].value}')
curl -s -H 'Host: shop.example.com' http://$GW/ | head -5      # frontend 페이지
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: other.example.com' http://$GW/   # 404 — 맞는 route 없음
# 주소에 닿지 않는 랩이면: kubectl get svc -A | grep -i nginx 로 NodePort 확인 → <노드IP>:<NodePort> 로 같은 curl
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: HTTPRoute는 `parentRefs`(Gateway 이름 + listener 이름 `sectionName`)로 붙고, `backendRefs[].port` 는 Service의 port다.
- **헷갈리는 지점**: Gateway의 `Programmed=True` 는 입구가 준비됐다는 뜻일 뿐 route가 붙었다는 뜻이 아닙니다. route 쪽 `status.parents[].conditions` 를 따로 봐야 합니다. `hostnames` 가 안 맞는 요청은 404, backend Service 참조가 틀리면 500, Service는 맞는데 Ready 파드가 없으면 503입니다.

## 참고 문서

시험 중에는 **gateway-api.sigs.k8s.io** 문서도 열람할 수 있습니다.

- 검색어: `gateway api`, `http routing`
- https://kubernetes.io/docs/concepts/services-networking/gateway/
- https://gateway-api.sigs.k8s.io/guides/http-routing/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
