# q09 — Route traffic with an Ingress · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`web` 네임스페이스의 두 애플리케이션이 호스트 이름 하나를 공유해야 한다.

1. `web` 에 Deployment `site` 와 `api` 를 각각 2 레플리카, 이미지 `registry.k8s.io/e2e-test-images/echoserver:2.5`, 컨테이너 포트 8080으로 만든다.
2. 각각 포트 80에서 8080으로 넘기는 ClusterIP Service `site-svc`, `api-svc` 로 노출한다.
3. 이 클러스터에 있는 IngressClass를 찾아 이름을 적는다.
4. `web` 에 호스트 `shop.example.com` 용 Ingress `shop-ingress` 를 그 클래스로 만든다. `/` 와 그 하위는 `site-svc:80`, `/api` 와 그 하위는 `api-svc:80` 으로 보낸다.
5. 정확히 `/health` 경로만 `api-svc:80` 으로 보내는 규칙을 추가한다. `/health/extra` 는 여기에 매칭되지 않아야 한다.
6. `curl` 과 `Host` 헤더로 세 경로를 모두 확인한다.
7. 규칙에서 `pathType` 을 빼면 어떻게 되는지 한 줄로 적는다.

## 모범 풀이

```bash
IMG=registry.k8s.io/e2e-test-images/echoserver:2.5
kubectl -n web create deploy site --image=$IMG --replicas=2 --port=8080
kubectl -n web create deploy api  --image=$IMG --replicas=2 --port=8080
kubectl -n web expose deploy site --name=site-svc --port=80 --target-port=8080
kubectl -n web expose deploy api  --name=api-svc  --port=80 --target-port=8080

kubectl get ingressclass
# NAME    CONTROLLER             ...
# nginx   k8s.io/ingress-nginx
```

명령형으로 한 번에 만들 수 있습니다. `--rule` 의 경로 끝에 `*` 를 붙이면 `pathType: Prefix`, 붙이지 않으면 `Exact` 가 됩니다.

```bash
kubectl -n web create ingress shop-ingress --class=nginx \
  --rule='shop.example.com/api*=api-svc:80' \
  --rule='shop.example.com/health=api-svc:80' \
  --rule='shop.example.com/*=site-svc:80'
```

같은 결과의 yaml입니다.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop-ingress
  namespace: web
spec:
  ingressClassName: nginx
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 80
```

나머지 두 경로도 같은 모양입니다. `/health` 는 `pathType: Exact` + `api-svc`, `/` 는 `pathType: Prefix` + `site-svc` 입니다.

**`pathType` 은 필수 필드입니다.** `networking.k8s.io/v1` 에서는 생략하면 기본값이 채워지는 게 아니라 검증 에러로 거부됩니다(`spec.rules[0].http.paths[0].pathType: Required value`). extensions/v1beta1 시절의 예제를 그대로 베끼면 여기서 막힙니다.

| pathType | 의미 | `/api/v1` 매칭 |
|---|---|---|
| `Prefix` | 경로를 `/` 로 나눈 요소 단위 접두 일치 | `/api` 가 매칭됨 |
| `Exact` | 완전 일치, 대소문자 구분 | 매칭 안 됨 |
| `ImplementationSpecific` | 컨트롤러가 정의 (nginx는 정규식으로 해석) | 컨트롤러에 따름 |

`Prefix` 는 문자열 접두가 아니라 **경로 요소 단위**입니다. `/api` 는 `/api/v1` 과 `/api` 에 매칭되지만 `/apifoo` 에는 매칭되지 않습니다.

경로 여러 개가 동시에 매칭되면 **가장 긴 것이 이깁니다**. 그래서 `/` 규칙과 `/api` 규칙이 함께 있어도 `/api/v1` 은 `api-svc` 로 갑니다. yaml에 적은 순서는 이 판정에 영향이 없습니다. 백엔드 구조도 v1에서 바뀌어 `serviceName`/`servicePort` 가 아니라 `service.name` + `service.port.number`(이름을 쓰려면 `service.port.name`)입니다.

## 검증

```bash
kubectl -n web describe ingress shop-ingress
# Rules 표에 세 경로와 백엔드가, Backend에 파드 IP:8080이 보여야 한다
# 백엔드가 <error: endpoints "api-svc" not found> 면 Service/셀렉터 문제
IP=$(kubectl -n web get ingress shop-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# 비어 있으면 kubectl -n ingress-nginx get svc 로 컨트롤러 NodePort를 확인해 그쪽을 친다
curl -s -H 'Host: shop.example.com' http://$IP/            | head -3   # site
curl -s -H 'Host: shop.example.com' http://$IP/api/v1      | head -3   # api
curl -s -H 'Host: shop.example.com' http://$IP/health      | head -3   # api
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: shop.example.com' http://$IP/health/extra
# Exact 규칙에 안 걸리고 / Prefix 로 떨어져 site-svc 응답(200)
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `pathType` 은 생략할 수 없다. `kubectl create ingress` 에서 경로 끝의 `*` 가 `Prefix`, 없으면 `Exact`.
- **헷갈리는 지점**: `ingressClassName`(spec 필드)과 옛 `kubernetes.io/ingress.class` 어노테이션을 혼동하는 것. 둘을 같이 쓰면 어노테이션이 우선해 엉뚱한 컨트롤러가 집어갈 수 있습니다. Ingress는 **네임스페이스 리소스**이므로 다른 네임스페이스의 Service를 백엔드로 지목할 수 없다는 점도 자주 놓칩니다.

## 참고 문서

- 검색어: `ingress path types`
- https://kubernetes.io/docs/concepts/services-networking/ingress/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
