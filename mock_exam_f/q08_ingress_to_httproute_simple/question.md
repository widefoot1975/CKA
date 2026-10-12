# q08 — Move an HTTP Ingress to an HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_f |
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
kubectl delete ns gateway blog --ignore-not-found --wait=true
kubectl create ns gateway
kubectl create ns blog

# 3) Gateway public-gw (listener http, 모든 네임스페이스의 route 허용) — kubectl create 로는 못 만들어서 이것만 YAML
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: public-gw, namespace: gateway}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces: {from: All}
YAML

# 4) 백엔드: 어떤 경로든 정해진 문자열을 돌려주는 http-echo (컨테이너 포트 5678)
kubectl -n blog create deploy blog     --image=hashicorp/http-echo:1.0 -- /http-echo -text=blog-web
kubectl -n blog create deploy blog-api --image=hashicorp/http-echo:1.0 -- /http-echo -text=blog-api
kubectl -n blog expose deploy blog     --port=80   --target-port=5678
kubectl -n blog expose deploy blog-api --port=8080 --target-port=5678

# 5) 옮길 대상 Ingress blog (/ → blog:80, /api → blog-api:8080, 둘 다 Prefix)
kubectl -n blog create ingress blog --class=nginx \
  --rule='blog.example.com/*=blog:80' \
  --rule='blog.example.com/api*=blog-api:8080'

kubectl -n blog rollout status deploy blog
kubectl -n blog rollout status deploy blog-api
kubectl -n gateway wait gateway public-gw --for=condition=Programmed --timeout=120s

# 6) 시작 상태 확인: public-gw PROGRAMMED True, blog 에는 Ingress 만 있고 HTTPRoute 없음
kubectl -n gateway get gateway public-gw
kubectl -n blog get deploy,svc,ingress,httproute
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `gateway` 에는 Gateway `public-gw` 가, `blog` 에는 Deployment·Service `blog`(80)와 `blog-api`(8080), 그리고 옮길 대상인 Ingress `blog` 가 있다. HTTPRoute 는 없고 문제 풀이에서 직접 만든다.
Ingress `blog` 는 옮길 규칙을 읽어 오는 원본일 뿐이라 Ingress 컨트롤러는 설치하지 않는다(ADDRESS 가 비어 있어도 정상).
NGINX Gateway Fabric 은 `gateway` 안에 데이터 플레인 Service(`public-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `gateway` 와 `blog` 만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns gateway blog --ignore-not-found
```

</details>

## Task

In namespace `blog`, Ingress `blog` publishes host `blog.example.com`: path `/` goes to
Service `blog` on port `80`, and path `/api` goes to Service `blog-api` on port `8080`.
The platform team runs Gateway `public-gw` in namespace `gateway`. Its listener `http`
(protocol HTTP, port 80) accepts routes from all namespaces. Service `blog` answers every
request with `blog-web`, Service `blog-api` answers every request with `blog-api`.

1. Create HTTPRoute `blog` in namespace `blog`, attached to listener `http` of Gateway
   `public-gw` in namespace `gateway`, with the same hostname and the same two path rules
   as Ingress `blog`.
2. Using the address of Gateway `public-gw` and the header `Host: blog.example.com`,
   verify that `/` reaches `blog` and `/api` reaches `blog-api`.
3. After the verification succeeds, delete Ingress `blog`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
