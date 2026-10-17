# q08 — Weighted traffic splitting with HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace 두 개
kubectl delete ns gateway-system shop --ignore-not-found --wait=true
kubectl create ns gateway-system
kubectl create ns shop

# 3) Gateway web-gw (listener http, 모든 네임스페이스의 route 허용) — kubectl create 로는 못 만들어서 YAML
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: web-gw, namespace: gateway-system}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces: {from: All}
YAML

# 4) Deployment shop-v1 / shop-v2 (nginx:1.27, 컨테이너 포트 80)
#    어떤 경로든 200 과 자기 이름(shop-v1 / shop-v2)을 돌려주도록 nginx 설정만 바꾼다. Service 는 문제에서 만든다.
for v in v1 v2; do
kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: shop-$v, namespace: shop, labels: {app: shop-$v}}
spec:
  replicas: 1
  selector: {matchLabels: {app: shop-$v}}
  template:
    metadata: {labels: {app: shop-$v, version: $v}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports: [{containerPort: 80}]
        command: ["/bin/sh", "-c"]
        args:
        - |
          echo 'server { listen 80; location / { default_type text/plain; return 200 "shop-$v\n"; } }' > /etc/nginx/conf.d/default.conf
          exec nginx -g 'daemon off;'
YAML
done
kubectl -n shop rollout status deploy shop-v1
kubectl -n shop rollout status deploy shop-v2
kubectl -n gateway-system wait gateway web-gw --for=condition=Programmed --timeout=120s

# 5) 시작 상태 확인: web-gw PROGRAMMED True, shop 에는 Deployment 두 개만 있고 Service·HTTPRoute 없음
kubectl -n gateway-system get gateway web-gw
kubectl -n shop get deploy,svc,httproute
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `gateway-system` 에는 Gateway `web-gw` 가, `shop` 에는 Deployment `shop-v1`·`shop-v2` 만 있고 Service 와 HTTPRoute 는 없다. 문제 풀이에서 직접 만든다.
두 Deployment 는 `nginx:1.27`(컨테이너 포트 80)이고, 비율을 눈으로 셀 수 있도록 어떤 경로든 `shop-v1` / `shop-v2` 를 돌려주게 nginx 설정만 바꿨다.
NGINX Gateway Fabric 은 `gateway-system` 안에 데이터 플레인 Service(`web-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `gateway-system` 과 `shop` 만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns gateway-system shop --ignore-not-found
```

</details>

## Task

The Gateway API CRDs are installed and a Gateway named `web-gw` exists in namespace
`gateway-system` with an HTTP listener named `http` on port 80 that allows routes from
all namespaces.

In namespace `shop`:

1. Confirm the Gateway API is available and report the API group and version of the
   `HTTPRoute` resource.
2. Deployments `shop-v1` and `shop-v2` already exist. Create ClusterIP Services
   `shop-v1` and `shop-v2`, port 80 targeting container port 80.
3. Create an HTTPRoute `shop-route` attached to `web-gw`, for hostname
   `shop.example.com`, matching path prefix `/`, that sends 90% of requests to `shop-v1`
   and 10% to `shop-v2`.
4. Add a second rule on path prefix `/canary` that sends **all** traffic to `shop-v2`,
   regardless of the weighting above.
5. Confirm the route was accepted by the Gateway and that the parent reference resolved.
6. State in one line what the numbers in `weight` actually mean.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
