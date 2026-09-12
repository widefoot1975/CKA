# q09 — Path-based routing with an Ingress · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터에 Ingress 컨트롤러가 이미 설치되어 있다.

1. `web` 네임스페이스에 이미지 `nginx`, replicas 2인 Deployment `api` 와 `ui` 를 만들고, 각각 포트 80의 ClusterIP Service `api-svc`, `ui-svc` 로 노출한다.
2. 호스트 `shop.example.com` 에 대한 Ingress `app-ingress` 를 만들어 다음과 같이 라우팅한다.
   - `/api` 요청 → `api-svc:80`
   - `/` 요청 → `ui-svc:80`
3. `pathType: Prefix` 를 사용한다.
4. Ingress에 주소가 할당되었는지, 규칙이 의도대로 들어갔는지 확인한다.

## 모범 풀이

```bash
kubectl create namespace web

kubectl -n web create deploy api --image=nginx --replicas=2
kubectl -n web create deploy ui  --image=nginx --replicas=2

kubectl -n web expose deploy api --name=api-svc --port=80 --target-port=80
kubectl -n web expose deploy ui  --name=ui-svc  --port=80 --target-port=80
```

Ingress는 규칙이 두 개라 yaml이 편합니다.

```bash
kubectl -n web create ingress app-ingress \
  --rule='shop.example.com/api*=api-svc:80' \
  --rule='shop.example.com/*=ui-svc:80' \
  --dry-run=client -o yaml > ing.yaml
kubectl apply -f ing.yaml
```

`--rule` 에서 경로 끝에 `*` 를 붙이면 `pathType: Prefix` 로 생성됩니다. 결과:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: web
spec:
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
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ui-svc
            port:
              number: 80
```

더 구체적인 경로(`/api`)를 먼저 두는 것이 안전합니다. `ingressClassName` 을 요구하는 문제라면 `--class=nginx` 를 추가합니다.

## 검증

```bash
kubectl -n web get ingress app-ingress
kubectl -n web describe ingress app-ingress          # Rules 섹션 확인
kubectl -n web get ingress app-ingress -o jsonpath='{.spec.rules[0].http.paths[*].path}'; echo

# 컨트롤러 주소로 Host 헤더를 실어 확인
curl -s -H 'Host: shop.example.com' http://<ingress-address>/api | head -3
curl -s -H 'Host: shop.example.com' http://<ingress-address>/    | head -3
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `pathType` 은 필수 필드입니다. 빼면 생성이 거부됩니다.
- **헷갈리는 지점**: backend 구조가 `service.name` + `service.port.number` 로 중첩입니다. 구버전 문법(`serviceName`/`servicePort`)을 쓰면 안 됩니다.

## 참고 문서

- 검색어: `ingress`
- https://kubernetes.io/docs/concepts/services-networking/ingress/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
