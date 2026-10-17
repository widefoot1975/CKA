# q14 — Gateway accepts traffic but nothing reaches the backend

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (트러블슈팅 문제라 명령어에 답이 보인다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

<details><summary>설정 명령 펼치기 (답 포함)</summary>

```bash
# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace gw (cleanup.sh 가 이 문제의 gw 인지 알아보도록 라벨을 붙인다)
kubectl delete ns gw --ignore-not-found --wait=true
rm -rf /opt/q14
kubectl create ns gw
kubectl label ns gw cka-lab=b14
mkdir -p /opt/q14

# 3) Gateway main-gw (listener http · HTTP · 80) — 이 설정은 정상이고 문제에서 바꾸지 않는다
kubectl apply -f - <<'YAML'
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
      namespaces: {from: Same}
YAML

# 4) 백엔드 shop-svc(80→80) / api-svc(8080→80)
#    어느 쪽으로 갔는지 보이도록 nginx 가 어떤 경로든 200 과 자기 이름을 돌려준다.
for app in shop-svc api-svc; do
kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: $app, namespace: gw, labels: {app: $app}}
spec:
  replicas: 1
  selector: {matchLabels: {app: $app}}
  template:
    metadata: {labels: {app: $app}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports: [{containerPort: 80}]
        command: ["/bin/sh", "-c"]
        args:
        - |
          echo 'server { listen 80; location / { default_type text/plain; return 200 "$app\n"; } }' > /etc/nginx/conf.d/default.conf
          exec nginx -g 'daemon off;'
YAML
done
kubectl -n gw expose deploy shop-svc --port=80 --target-port=80
kubectl -n gw expose deploy api-svc --port=8080 --target-port=80

# 5) 장애가 든 HTTPRoute 두 개 (내용은 풀이에서 확인)
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: store-route, namespace: gw}
spec:
  parentRefs:
  - name: main-gw
    sectionName: http
  hostnames:
  - shop.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /}
    backendRefs:
    - {name: shop-svc, port: 80}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: api-route, namespace: gw}
spec:
  parentRefs:
  - name: main-gw
    sectionName: http
  hostnames:
  - store.example.com
  rules:
  - matches:
    - path: {type: PathPrefix, value: /api}
    backendRefs:
    - {name: api-svc, port: 80}
YAML

kubectl -n gw rollout status deploy shop-svc --timeout=120s
kubectl -n gw rollout status deploy api-svc --timeout=120s
kubectl -n gw wait gateway main-gw --for=condition=Programmed --timeout=120s

# 6) 시작 상태 확인: Gateway PROGRAMMED True, 서비스 두 개, HTTPRoute 두 개
kubectl -n gw get gateway,svc,httproute
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 Gateway `main-gw` 는 `Programmed` 이고 `shop-svc`·`api-svc` 는 Running 이다. HTTPRoute 두 개 중 고장 난 곳을 찾아 고치는 것이 문제다.
두 백엔드는 어떤 경로든 `200` 과 자기 이름(`shop-svc` / `api-svc`)을 돌려주므로, curl 응답 본문으로 어느 backend 에 닿았는지 바로 보인다.
NGINX Gateway Fabric 은 Gateway 마다 같은 네임스페이스에 데이터 플레인 Service(`main-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
**namespace `gw` 와 리소스 이름이 q08 과 같다.** 설정하면 `gw` 를 지우고 새로 만들므로 q08 결과가 남아 있으면 사라진다.
정리할 때는 이 문제가 만든 `gw`(라벨 `cka-lab=b14`)와 `/opt/q14` 만 지우고, NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 남겨 둔다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
[ "$(kubectl get ns gw -o jsonpath='{.metadata.labels.cka-lab}' 2>/dev/null)" = "b14" ] \
  && kubectl delete ns gw --ignore-not-found
rm -rf /opt/q14
```

</details>

## Task

In namespace `gw`, Gateway `main-gw` has an address and its `http` listener is
`Programmed`. Services `shop-svc` (port `80`) and `api-svc` (port `8080`) are Running with
healthy endpoints. Two HTTPRoutes are meant to serve host `store.example.com` through that
listener: `store-route` sends `/` to `shop-svc`, and `api-route` sends `/api` to `api-svc`.
But `curl -H 'Host: store.example.com' http://<gw-address>/` returns `404` and `/api`
returns `500`.

Fix the routing. Do **not** change the Gateway's listener configuration and do not change
either Service.

1. Write the `Accepted` and `ResolvedRefs` conditions of both HTTPRoutes, with their
   reasons, to `/opt/q14/conditions.txt`.
2. Decide for each of the two failing paths whether the fault is route attachment,
   hostname matching, or backend resolution.
3. Repair the routes so `/` reaches `shop-svc` and `/api` reaches `api-svc`.
4. Verify both paths return `200` from the correct backend.
5. Write the root cause of each symptom in one line each to `/opt/q14/cause.txt`, plus the
   status code you would expect instead if `api-svc` were valid but had no ready endpoints.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
