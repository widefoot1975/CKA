# q09 — Migrate a TLS Ingress to the Gateway API · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `secure` 는 Deployment `portal`(3 레플리카, `nginx:1.27`, 포트 80)을 Service `portal`
(포트 80)과 Ingress `portal-ing`(IngressClass `nginx`)로 서비스하고 있다. 이 Ingress는 Secret
`portal-tls` 로 `portal.example.com` 의 TLS를 종료한다. Ingress NGINX 컨트롤러가 은퇴했으므로 이
사이트를 Gateway API로 옮겨야 한다. GatewayClass `nginx` 는 설치되어 있고 `Accepted` 다.

1. 기존 Ingress에서 호스트, TLS Secret, 백엔드 Service와 포트를 읽어 `/opt/course/q09/ingress.txt` 에 쓴다.
2. `secure` 에 gatewayClassName `nginx` 인 Gateway `portal-gw` 를 만든다. listener는 하나, 이름 `https`,
   protocol `HTTPS`, port `443`, hostname `portal.example.com`, Secret `portal-tls` 로 TLS를 종료한다.
3. `secure` 에 `https` listener에 붙는 HTTPRoute `portal-route` 를 만든다. hostname
   `portal.example.com`, path prefix `/` 를 Service `portal` 포트 80으로 보낸다.
4. Gateway를 통한 HTTPS가 페이지를 서비스하는지, 제시된 인증서의 subject가 `portal.example.com`
   인지, listener가 `ResolvedRefs=True` 와 `Programmed=True` 를 보고하는지 확인한다.
5. 4번이 성공한 **뒤에만** Ingress를 지운다.
6. `portal-tls` 가 `secure` 가 아니라 `certs` 네임스페이스에 있었다면 무엇이 더 필요한지 한 줄로 적는다.

## 모범 풀이

**1) 기존 Ingress에서 옮길 정보를 뽑습니다**

```bash
mkdir -p /opt/course/q09
kubectl -n secure get ingress portal-ing -o jsonpath=\
'host={.spec.rules[0].host}{"\n"}secret={.spec.tls[0].secretName}{"\n"}backend={.spec.rules[0].http.paths[0].backend.service.name}:{.spec.rules[0].http.paths[0].backend.service.port.number}{"\n"}' \
  | tee /opt/course/q09/ingress.txt
# host=portal.example.com
# secret=portal-tls
# backend=portal:80

kubectl -n secure get secret portal-tls        # TYPE kubernetes.io/tls, DATA 2 (tls.crt, tls.key)
```

**Ingress → Gateway API 대응표** — 마이그레이션은 이 표대로 필드를 옮기는 작업입니다.

| Ingress | Gateway API |
|---|---|
| `spec.ingressClassName` | Gateway `spec.gatewayClassName` |
| `spec.tls[].hosts` + `secretName` | Gateway listener `hostname` + `tls.certificateRefs` (`mode: Terminate`) |
| `spec.rules[].host` | HTTPRoute `spec.hostnames` |
| `path` + `pathType: Prefix` | HTTPRoute `matches[].path` (`type: PathPrefix`) |
| `backend.service.name` / `port.number` | HTTPRoute `backendRefs[].name` / `port` |
| 컨트롤러 어노테이션(`ssl-redirect`, `rewrite-target` …) | HTTPRoute `filters` (`RequestRedirect`, `URLRewrite` …) — 표준 필드 |

Ingress는 한 오브젝트에 "입구"와 "라우팅"이 섞여 있고 세부 동작을 컨트롤러별 어노테이션에 맡겼습니다.
Gateway API는 입구(Gateway, 보통 플랫폼 팀)와 라우팅(HTTPRoute, 앱 팀)을 나누고, 어노테이션 대신
표준 필드로 표현합니다.

**2~3) Gateway 와 HTTPRoute**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: portal-gw
  namespace: secure
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    hostname: portal.example.com
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: portal-tls          # 같은 네임스페이스의 kubernetes.io/tls Secret
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: portal-route
  namespace: secure
spec:
  parentRefs:
  - name: portal-gw
    sectionName: https            # listener 이름
  hostnames:
  - portal.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - name: portal
      port: 80                    # Service 의 port
```

```bash
kubectl apply -f portal-gw.yaml
```

컨트롤러는 Secret의 **`tls.crt` 와 `tls.key` 키**를 읽습니다. `kubectl create secret tls` 로 만든
`kubernetes.io/tls` Secret이면 키 이름이 자동으로 맞습니다. 인증서가 없어 새로 만들어야 한다면:

```bash
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=portal.example.com" -addext "subjectAltName=DNS:portal.example.com"
kubectl -n secure create secret tls portal-tls --cert=tls.crt --key=tls.key
```

`-addext` 의 SAN이 없으면 최신 클라이언트는 CN만으로 호스트를 검증하지 않아 `curl` 이
"no alternative certificate subject name matches" 로 거부합니다(`-k` 로 검증을 끄면 보이지 않음).

**원래 동작을 보존하려면** — ingress-nginx는 TLS가 설정된 호스트의 HTTP 요청을 기본으로 HTTPS로
리다이렉트했습니다. Gateway API에서는 이것이 자동이 아니므로, 같은 동작이 필요하면 `http` listener(포트
80)를 추가하고 `RequestRedirect` 필터(`scheme: https`)를 가진 HTTPRoute를 그 listener에 붙입니다.
이 문제는 요구하지 않습니다.

## 검증

```bash
kubectl -n secure get gateway portal-gw
# NAME        CLASS   ADDRESS        PROGRAMMED   AGE
# portal-gw   nginx   10.96.40.12    True

kubectl -n secure get gateway portal-gw -o jsonpath=\
'{range .status.listeners[0].conditions[*]}{.type}={.status} ({.reason}){"\n"}{end}'
# Accepted=True / Programmed=True / ResolvedRefs=True / Conflicted=False

kubectl -n secure get httproute portal-route -o jsonpath=\
'{range .status.parents[0].conditions[*]}{.type}={.status}{"\n"}{end}'
# Accepted=True / ResolvedRefs=True

GW=$(kubectl -n secure get gateway portal-gw -o jsonpath='{.status.addresses[0].value}')
curl -sk --resolve portal.example.com:443:$GW https://portal.example.com/ | head -3   # nginx 기본 페이지
curl -vk --resolve portal.example.com:443:$GW https://portal.example.com/ 2>&1 | grep subject
# subject: CN=portal.example.com

kubectl -n secure delete ingress portal-ing          # 5) 새 경로가 확인된 뒤에만
kubectl -n secure get endpointslice -l kubernetes.io/service-name=portal   # 파드 IP 3개
```

Secret이 없거나 키가 틀리면 listener에 `ResolvedRefs=False (InvalidCertificateRef)` 가 찍히고 HTTPS
listener가 프로그래밍되지 않습니다. 옛 Ingress의 "fake certificate가 나온다"보다 원인이 명확하게 드러납니다.

**6) 다른 네임스페이스의 Secret** — Ingress는 `secretName` 에 네임스페이스를 쓸 수 없어 같은
네임스페이스의 Secret만 참조합니다. Gateway API는 `certificateRefs` 에 `namespace: certs` 를 쓸 수
있지만, **Secret이 있는 쪽(`certs`)에 그 참조를 허락하는 `ReferenceGrant`** 가 있어야 합니다. 없으면
listener가 `ResolvedRefs=False (RefNotPermitted)` 가 됩니다.

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1   # 설치된 버전은 kubectl api-resources 로 확인
kind: ReferenceGrant
metadata:
  name: allow-secure-gateways
  namespace: certs                  # 참조를 "받는" 쪽 네임스페이스
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: Gateway
    namespace: secure
  to:
  - group: ""
    kind: Secret
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Ingress의 `tls` 블록은 Gateway **listener**(`protocol: HTTPS`, `tls.mode: Terminate`, `certificateRefs`)로, `rules` 는 **HTTPRoute** 로 옮긴다. 새 경로를 검증한 뒤에 Ingress를 지운다.
- **헷갈리는 지점**: listener의 `hostname` 과 HTTPRoute의 `hostnames` 는 교집합이 있어야 route가 붙습니다(없으면 `Accepted=False, NoMatchingListenerHostname`). 다른 네임스페이스의 Secret이나 Service를 참조하려면 참조를 **받는** 네임스페이스에 ReferenceGrant가 필요합니다. 그리고 ingress-nginx가 해 주던 HTTP→HTTPS 리다이렉트 같은 기본 동작은 Gateway API에서 자동이 아니므로 필요하면 직접 선언합니다.

## 참고 문서

- 검색어: `gateway api`, `migrating from ingress`
- https://kubernetes.io/docs/concepts/services-networking/gateway/
- https://gateway-api.sigs.k8s.io/guides/migrating-from-ingress/
- https://gateway-api.sigs.k8s.io/guides/tls/
- https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
