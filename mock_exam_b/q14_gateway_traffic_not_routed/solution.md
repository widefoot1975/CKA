# q14 — Gateway accepts traffic but nothing reaches the backend · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`gw` 네임스페이스의 Gateway `main-gw` 는 주소를 가지고 있고 `http` listener는 `Programmed` 다.
서비스 `shop-svc`(port `80`)와 `api-svc`(port `8080`)는 Running이고 endpoint도 정상이다.
HTTPRoute 두 개가 그 listener로 호스트 `store.example.com` 을 서비스해야 한다 — `store-route` 는
`/` 를 `shop-svc` 로, `api-route` 는 `/api` 를 `api-svc` 로 보낸다. 그런데
`curl -H 'Host: store.example.com' http://<gw-address>/` 는 `404`, `/api` 는 `500` 이다.

라우팅을 고친다. Gateway의 listener 설정과 두 Service는 **바꾸지 않는다**.

1. 두 HTTPRoute의 `Accepted` 와 `ResolvedRefs` condition을 reason과 함께
   `/opt/q14/conditions.txt` 에 적는다.
2. 실패하는 두 경로 각각에 대해 원인이 route 부착인지, hostname 매칭인지, backend 해석인지 판단한다.
3. `/` 는 `shop-svc` 로, `/api` 는 `api-svc` 로 가도록 route를 고친다.
4. 두 경로가 올바른 backend에서 `200` 을 반환하는지 확인한다.
5. 두 증상의 근본 원인을 각각 한 줄로 `/opt/q14/cause.txt` 에 적고, `api-svc` 가 유효하지만
   ready endpoint가 하나도 없었다면 대신 어떤 상태 코드를 기대하는지도 적는다.

## 모범 풀이

Gateway API 문제는 **status condition 이 어디서 끊겼는지** 읽는 것이 전부입니다. 404와 500은
서로 다른 단계의 실패이므로 하나의 원인으로 묶어 생각하면 안 됩니다.

**1단계 — Gateway 쪽은 이미 정상임을 확인해 조사 범위를 줄입니다.**

```bash
kubectl -n gw get gateway main-gw -o jsonpath='{.status.listeners[0].attachedRoutes}{"\n"}'
# 2  ← 두 route 모두 listener 에 붙어 있다. 0 이면 부착(parentRefs/allowedRoutes) 문제
```

**2단계 — 두 HTTPRoute 의 condition 을 읽습니다.**

```bash
for r in store-route api-route; do
  echo "== $r"
  kubectl -n gw get httproute $r -o jsonpath=\
'{range .status.parents[0].conditions[*]}{.type}={.status} ({.reason}) {.message}{"\n"}{end}'
done | tee /opt/q14/conditions.txt
# == store-route
# Accepted=True (Accepted)
# ResolvedRefs=True (ResolvedRefs)
# == api-route
# Accepted=True (Accepted)
# ResolvedRefs=False (BackendNotFound) ... port 80 ...   ← reason 문자열은 구현마다 다를 수 있다
```

`store-route` 는 condition이 **전부 True** 인데도 404입니다. condition은 "설정이 유효한가"만
말하고 "요청이 이 route에 매칭되는가"는 말해 주지 않기 때문입니다. 반면 `api-route` 의
`ResolvedRefs=False` 는 backendRef 하나가 해석되지 않는다는 뜻입니다. reason 문자열은
구현체마다 다르므로(`BackendNotFound`, `UnsupportedValue` 등) **message 를 읽습니다.**

**3단계 — 실제 매니페스트에서 두 결함을 찾습니다.**

```bash
kubectl -n gw get httproute store-route api-route -o yaml
```

```yaml
# store-route
spec:
  hostnames:
  - shop.example.com          # (A) 요청 Host 는 store.example.com  →  404
  rules:
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - {name: shop-svc, port: 80}
---
# api-route
spec:
  hostnames:
  - store.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /api}
    backendRefs:              # matches 와 형제 키다. path 와 같은 깊이로 쓰면 거부된다
    - name: api-svc
      port: 80                # (B) api-svc 는 8080 만 노출  →  500
```

- **404 의 원인 (hostname 매칭)**: `store-route` 의 `hostnames` 가 `shop.example.com` 이라
  `Host: store.example.com` 의 `/` 요청과 매칭되는 route가 없습니다. 매칭되는 route가 없으면
  Gateway는 404를 냅니다. `/api` 요청은 hostname이 맞는 `api-route` 에 매칭되므로 404가 아니라
  다음 단계(backend)까지 갑니다 — 두 증상이 동시에 나타나는 이유입니다.
- **500 의 원인 (backend 해석)**: `backendRefs.port` 는 **Service의 port** 여야 합니다.
  `api-svc` 는 `8080` 만 노출하므로 `80` 은 없는 포트이고 backendRef가 무효가 됩니다.
  Gateway API 스펙은 **무효한 backendRef로 가야 할 요청에 500을 반드시(MUST) 반환**하도록
  정합니다. 컨테이너 포트(80)와 서비스 포트(8080)를 혼동해서 생기는 대표적 실수입니다.

| 증상 / condition | 원인 | 조치 |
|---|---|---|
| `attachedRoutes` 0, `Accepted=False (NotAllowedByListeners)` | listener의 `allowedRoutes.namespaces.from` 이 route 네임스페이스를 막음 | route를 같은 ns로 옮기거나 listener 허용(여기선 금지) |
| `Accepted=False (NoMatchingParent)` | `parentRefs` 의 name 또는 `sectionName` 오타 | parentRefs 수정 |
| `Accepted=False (NoMatchingListenerHostname)` | route hostname이 listener hostname과 교집합 없음 | hostname 수정 |
| 모든 condition True + **404** | 요청 Host/경로가 route의 `hostnames`·`matches` 와 불일치 | hostname 또는 path 수정 |
| `ResolvedRefs=False` + **500** | backendRef의 Service 이름·포트가 없음, 또는 다른 ns 참조에 ReferenceGrant 없음(`RefNotPermitted`) | 이름·포트 수정, ReferenceGrant 생성 |
| 모든 condition True + **503** | backendRef는 유효하지만 Service에 ready endpoint가 없음 | `kubectl get endpointslice -l kubernetes.io/service-name=<svc>` |

**4단계 — 수정.**

```bash
kubectl -n gw patch httproute store-route --type=json \
  -p='[{"op":"replace","path":"/spec/hostnames/0","value":"store.example.com"}]'
kubectl -n gw patch httproute api-route --type=json \
  -p='[{"op":"replace","path":"/spec/rules/0/backendRefs/0/port","value":8080}]'
```

`port` 값은 문자열이 아니라 정수여야 합니다. `"8080"` 으로 주면 스키마 검증에서 거부됩니다.

같은 listener·같은 hostname에 route가 둘 붙으면 구현이 규칙을 합쳐서 매칭합니다. 경로는
**가장 긴 prefix 우선**이므로 `/api/...` 는 `api-route`, 나머지는 `store-route` 로 갑니다.

**5번 답**: 원인은 위 두 줄이고, `api-svc` 가 유효한데 ready endpoint만 없었다면 스펙이 권고(SHOULD)하는
응답은 **503** 입니다. 즉 404(매칭 route 없음) → 500(backendRef 무효) → 503(endpoint 없음) 순서로
실패 단계가 깊어집니다.

## 검증

```bash
ADDR=$(kubectl -n gw get gateway main-gw -o jsonpath='{.status.addresses[0].value}')

curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: store.example.com' http://$ADDR/      # 200
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: store.example.com' http://$ADDR/api/  # 200

for r in store-route api-route; do
  kubectl -n gw get httproute $r -o jsonpath=\
'{range .status.parents[0].conditions[*]}{.type}={.status}{" "}{end}{"\n"}'
done
# Accepted=True ResolvedRefs=True  (두 줄 모두)

kubectl -n gw get gateway main-gw -o jsonpath='{.status.listeners[0].attachedRoutes}{"\n"}'  # 2
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: HTTPRoute의 모든 condition이 True인데도 404가 나오면 `hostnames` 또는 path match가 요청과 안 맞는 것이다. condition은 "설정이 유효한가"만 말하고 "요청이 매칭되는가"는 말해주지 않는다.
- **헷갈리는 지점**: 상태 코드가 실패 단계를 알려 줍니다 — 404는 매칭되는 route가 없음(호스트/경로), 500은 route는 맞았지만 backendRef가 무효(이름·포트·ReferenceGrant), 503은 backendRef는 유효하지만 ready endpoint가 없음. 그리고 `backendRefs.port` 는 Service의 `port` 이며 `targetPort` 나 컨테이너 포트가 아닙니다.

## 참고 문서

- 검색어: `httproute`
- https://kubernetes.io/docs/concepts/services-networking/gateway/
- https://gateway-api.sigs.k8s.io/reference/api-types/httproute/
- https://gateway-api.sigs.k8s.io/guides/http-routing/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
