# q08 — Expose a service with the Gateway API · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터에 NGINX Gateway 컨트롤러는 설치되어 있지만 Gateway API 타입은 아직 서비스되지 않는다.

1. Gateway API **standard** CRD를 설치하고, `gateway.networking.k8s.io/v1` 이 서비스되며
   `GatewayClass` `nginx` 가 존재하고 `Accepted` 인지 확인한다.
2. `gw` 네임스페이스에 deployment/service `shop-svc`(`nginx:1.27`, service port `80`)와
   `api-svc`(`nginx:1.27`, service port `8080` → container port `80`)를 만든다.
3. `gw` 에 gatewayClassName `nginx` 인 `Gateway` `main-gw` 를 만든다. listener 한 개,
   이름 `http`, protocol `HTTP`, port `80`, HTTPRoute를 **모든 네임스페이스에서** 받는다.
4. `gw` 에 `main-gw` 에 붙는 `HTTPRoute` `store-route` 를 만든다. hostname
   `store.example.com`, `PathPrefix` `/api` → `api-svc:8080`, `PathPrefix` `/` → `shop-svc:80`.
5. Gateway listener가 `Programmed` 이고 HTTPRoute가 `Accepted=True`, `ResolvedRefs=True`
   인지 확인한다.

## 모범 풀이

**1) CRD 설치.** Gateway API는 쿠버네티스에 내장되어 있지 않습니다. 별도 CRD를 먼저 깔아야
`kubectl get gateway` 가 `the server doesn't have a resource type "gateway"` 를 벗어납니다.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
kubectl api-resources --api-group=gateway.networking.k8s.io
kubectl get gatewayclass nginx
# NAME    CONTROLLER                                   ACCEPTED
# nginx   gateway.nginx.org/nginx-gateway-controller   True
```

`standard-install.yaml` 은 GatewayClass / Gateway / HTTPRoute / GRPCRoute를 넣습니다.
TCPRoute나 TLSRoute는 `experimental-install.yaml` 쪽입니다.

**2) 백엔드**

```bash
kubectl create namespace gw
kubectl -n gw create deploy shop-svc --image=nginx:1.27
kubectl -n gw expose deploy shop-svc --port=80
kubectl -n gw create deploy api-svc --image=nginx:1.27
kubectl -n gw expose deploy api-svc --port=8080 --target-port=80
```

**3~4) Gateway 와 HTTPRoute**

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: main-gw, namespace: gw}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: store-route, namespace: gw}
spec:
  parentRefs:
  - name: main-gw
    sectionName: http          # listener 의 이름. 포트가 아니다
  hostnames:
  - store.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /api}
    backendRefs:
    - {name: api-svc, port: 8080}
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - {name: shop-svc, port: 80}
```

**`allowedRoutes.namespaces.from` 의 기본값은 `Same` 입니다.** 즉 아무것도 안 쓰면 Gateway와
같은 네임스페이스의 route만 붙습니다. 다른 네임스페이스의 HTTPRoute는 에러 없이 그냥 무시되고,
route의 `status.parents[].conditions` 에 `Accepted=False, reason: NotAllowedByListeners` 로만
남습니다. 문제가 "모든 네임스페이스"라고 했으니 `from: All` 을 명시해야 합니다.

`backendRefs[].port` 는 **Service의 포트**입니다. 컨테이너 포트가 아닙니다. 여기가 틀리면
`ResolvedRefs` 가 False가 되거나 트래픽이 503으로 떨어집니다.

경로 우선순위는 Ingress와 다릅니다. Gateway API는 스펙이 **가장 긴 경로 우선**을 규정하므로
`/api` 와 `/` 의 순서를 yaml에서 신경 쓸 필요가 없습니다.

## 검증

```bash
kubectl -n gw get gateway main-gw
# NAME      CLASS   ADDRESS        PROGRAMMED   AGE
# main-gw   nginx   10.96.12.34    True

kubectl -n gw get httproute store-route -o yaml | grep -A8 'conditions:'
# type: Accepted      status: "True"   reason: Accepted
# type: ResolvedRefs  status: "True"   reason: ResolvedRefs

ADDR=$(kubectl -n gw get gateway main-gw -o jsonpath='{.status.addresses[0].value}')
curl -s -H 'Host: store.example.com' http://$ADDR/       | head -3   # shop-svc
curl -s -H 'Host: store.example.com' http://$ADDR/api/   | head -3   # api-svc
curl -s -o /dev/null -w '%{http_code}\n' http://$ADDR/                # 404 (host 불일치)
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Gateway API CRD는 별도 설치(`standard-install.yaml`)가 필요하고, listener의 `allowedRoutes.namespaces.from` 기본값은 `Same` 이다.
- **헷갈리는 지점**: 상태 조건 세 개가 각각 다른 문제를 가리킵니다 — Gateway의 `Programmed` 는 컨트롤러가 실제로 프록시를 설정했다는 뜻, route의 `Accepted` 는 listener가 route를 받아들였다는 뜻, `ResolvedRefs` 는 backendRef가 실제 Service/포트로 해석되었다는 뜻입니다. 문제가 생기면 이 순서로 읽습니다. `parentRefs` 의 `sectionName` 은 listener **이름**이고 포트가 아닙니다.

## 참고 문서

- 검색어: `gateway api`
- https://kubernetes.io/docs/concepts/services-networking/gateway/
- https://gateway-api.sigs.k8s.io/guides/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
