# q14 — Gateway accepts traffic but nothing reaches the backend · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`gw` 네임스페이스의 Gateway `main-gw` 는 주소를 가지고 있고 `http` listener는 `Programmed` 다.
서비스 `shop-svc`(port `80`)와 `api-svc`(port `8080`)는 Running이고 endpoint도 정상이다.
그런데 `curl -H 'Host: store.example.com' http://<gw-address>/` 는 `404`, `/api` 는 `503` 이다.

라우팅을 고친다. Gateway의 listener 설정과 두 Service는 **바꾸지 않는다**.

1. HTTPRoute `store-route` 의 `Accepted` 와 `ResolvedRefs` condition을 reason과 함께
   `/opt/q14/conditions.txt` 에 적는다.
2. 실패하는 두 경로 각각에 대해 원인이 route 부착인지, hostname 매칭인지, backend 해석인지 판단한다.
3. `/` 는 `shop-svc` 로, `/api` 는 `api-svc` 로 가도록 `store-route` 를 수정한다.
4. 두 경로가 올바른 backend에서 `200` 을 반환하는지 확인한다.
5. 두 증상의 근본 원인을 각각 한 줄로 `/opt/q14/cause.txt` 에 적는다.

## 모범 풀이

Gateway API 문제는 **status condition 이 어디서 끊겼는지** 읽는 것이 전부입니다. 404와 503은
서로 다른 단계의 실패이므로 하나의 원인으로 묶어 생각하면 안 됩니다.

**1단계 — Gateway 쪽은 이미 정상임을 확인해 조사 범위를 줄입니다.**

```bash
kubectl -n gw get gateway main-gw -o yaml | yq '.status'
# listeners[0].attachedRoutes 값을 꼭 본다 — 0 이면 route 가 아예 안 붙은 것
```

**2단계 — HTTPRoute 의 condition 을 읽습니다.**

```bash
kubectl -n gw get httproute store-route -o jsonpath=\
'{range .status.parents[0].conditions[*]}{.type}={.status} ({.reason}) {.message}{"\n"}{end}'
# Accepted=True (Accepted)
# ResolvedRefs=False (BackendNotFound) port 80 not found on Service "gw/api-svc"
```

`Accepted=True` 이므로 route는 listener에 붙었습니다 — 부착 문제가 아닙니다. 반면
`ResolvedRefs=False` 는 규칙 중 하나의 `backendRefs` 가 해석되지 않는다는 뜻입니다. reason
문자열은 구현체마다 다르므로(`BackendNotFound`, `UnsupportedValue` 등) **reason 대신 message 를
읽습니다** — message가 문제를 정확히 지목합니다.

| 증상 / condition | 원인 | 조치 |
|---|---|---|
| `Accepted=False (NotAllowedByListeners)` | listener의 `allowedRoutes.namespaces.from` 이 route 네임스페이스를 막음 | route를 같은 ns로 옮기거나 listener 허용(여기선 금지) |
| `Accepted=False (NoMatchingParent)` | `parentRefs` 의 name 또는 `sectionName` 오타 | parentRefs 수정 |
| `Accepted=False (NoMatchingListenerHostname)` | route hostname이 listener hostname과 교집합 없음 | hostname 수정 |
| `Accepted=True` + **404** | 요청 Host가 route의 `hostnames` 와 불일치 | hostname 또는 요청 Host 수정 |
| `ResolvedRefs=False (BackendNotFound)` | backendRef의 Service 이름이 없음 | 이름 수정 |
| `ResolvedRefs=False (RefNotPermitted)` | 다른 네임스페이스의 Service를 ReferenceGrant 없이 참조 | ReferenceGrant 생성 |
| `ResolvedRefs=False` + message가 포트를 지목 / 또는 True인데 **503** | backendRef `port` 가 Service에 없는 포트 | port를 Service의 `port` 값으로 수정 |
| 모든 condition True인데 **503** | Service의 endpoint가 비어 있음 | `kubectl get endpointslice` 확인 |

**3단계 — 실제 매니페스트에서 두 결함을 찾습니다.** `kubectl -n gw get httproute store-route -o yaml`

```yaml
spec:
  hostnames:
  - shop.example.com          # (A) 요청 Host 는 store.example.com  →  404
  rules:
  - matches:
    - path: {type: PathPrefix, value: /api}
    backendRefs:              # matches 와 형제 키다. path 와 같은 깊이로 쓰면 거부된다
    - name: api-svc
      port: 80                # (B) api-svc 는 8080 만 노출  →  503
```

- **404 의 원인**: `hostnames` 가 `shop.example.com` 이라 `Host: store.example.com` 요청이
  어떤 route와도 매칭되지 않습니다. 매칭되는 route가 없으면 Gateway는 **listener 기본 응답인
  404** 를 냅니다. condition은 전부 True인데도 404가 나는 유일한 경우가 이것이라서, condition만
  보고 "정상"이라 판단하면 못 찾습니다.
- **503 의 원인**: `backendRefs.port` 는 **Service의 port** 여야 합니다. `api-svc` 는 `8080` 만
  노출하므로 `80` 은 존재하지 않는 포트이고, 프록시는 보낼 endpoint를 얻지 못해 503을 냅니다.
  컨테이너 포트(80)와 서비스 포트(8080)를 혼동해서 생기는 대표적 실수입니다.

**4단계 — 수정.**

```bash
kubectl -n gw patch httproute store-route --type=json -p='[
  {"op":"replace","path":"/spec/hostnames/0","value":"store.example.com"},
  {"op":"replace","path":"/spec/rules/0/backendRefs/0/port","value":8080}
]'
```

`port` 값은 문자열이 아니라 정수여야 합니다. `"8080"` 으로 주면 스키마 검증에서 거부됩니다.

## 검증

```bash
ADDR=$(kubectl -n gw get gateway main-gw -o jsonpath='{.status.addresses[0].value}')

curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: store.example.com' http://$ADDR/      # 200
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: store.example.com' http://$ADDR/api/  # 200
curl -s -H 'Host: store.example.com' http://$ADDR/api/ | grep -o 'api-svc\|nginx'

kubectl -n gw get httproute store-route -o jsonpath=\
'{range .status.parents[0].conditions[*]}{.type}={.status}{"\n"}{end}'
# Accepted=True / ResolvedRefs=True

kubectl -n gw get gateway main-gw -o jsonpath='{.status.listeners[0].attachedRoutes}{"\n"}'  # 1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: HTTPRoute의 모든 condition이 True인데도 404가 나오면 `hostnames` 또는 path match가 요청과 안 맞는 것이다. condition은 "설정이 유효한가"만 말하고 "요청이 매칭되는가"는 말해주지 않는다.
- **헷갈리는 지점**: 404와 503이 가리키는 단계가 다릅니다 — 404는 매칭되는 route가 없다(호스트/경로 문제), 503은 route는 맞았지만 보낼 endpoint가 없다(backend/포트 문제). 그리고 `backendRefs.port` 는 Service의 `port` 이며 `targetPort` 나 컨테이너 포트가 아닙니다.

## 참고 문서

- 검색어: `httproute`
- https://kubernetes.io/docs/concepts/services-networking/gateway/
- https://gateway-api.sigs.k8s.io/guides/http-routing/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
