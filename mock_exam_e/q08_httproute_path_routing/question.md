# q08 — Route two paths with one HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `infra` 는 C05 가, `shop` 은 A08·A15·C06·C08·D05·F15 가 함께 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다. `mock_exam_c/q08` 도 `shop` 에 HTTPRoute `shop-route` 를 만들므로 두 문제를 동시에 펼쳐 두지 않는다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 (이 문제가 만드는 오브젝트만)
kubectl -n shop delete httproute shop-route --ignore-not-found 2>/dev/null || true
kubectl -n shop delete svc catalog cart --ignore-not-found 2>/dev/null || true
kubectl -n shop delete deploy catalog cart --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n infra delete gateway main-gw --ignore-not-found 2>/dev/null || true
#    namespace 두 개 — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns infra >/dev/null 2>&1; then
  kubectl create ns infra
  kubectl label ns infra cka-lab-e08=created --overwrite
fi
if ! kubectl get ns shop >/dev/null 2>&1; then
  kubectl create ns shop
  kubectl label ns shop cka-lab-e08=created --overwrite
fi

# 3) Gateway main-gw (listener http, 모든 네임스페이스의 route 허용) — kubectl create 로는 못 만들어서 이것만 YAML
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: main-gw, namespace: infra}
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces: {from: All}
YAML

# 4) 백엔드: 어떤 경로든 자기 이름을 돌려주는 http-echo (컨테이너 포트 5678)
kubectl -n shop create deploy catalog --image=hashicorp/http-echo:1.0 -- /http-echo -text=catalog
kubectl -n shop create deploy cart    --image=hashicorp/http-echo:1.0 -- /http-echo -text=cart
kubectl -n shop expose deploy catalog --port=80   --target-port=5678
kubectl -n shop expose deploy cart    --port=8080 --target-port=5678
kubectl -n shop rollout status deploy catalog
kubectl -n shop rollout status deploy cart
kubectl -n infra wait gateway main-gw --for=condition=Programmed --timeout=120s

# 5) 시작 상태 확인: main-gw PROGRAMMED True, shop 에는 HTTPRoute 없음
kubectl -n infra get gateway main-gw
kubectl -n shop get deploy,svc,httproute
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `infra` 에는 Gateway `main-gw` 가, `shop` 에는 Deployment·Service `catalog`(80)와 `cart`(8080)가 있고 HTTPRoute 는 없다. 문제 풀이에서 직접 만든다.
NGINX Gateway Fabric 은 `infra` 안에 데이터 플레인 Service(`main-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `infra` 와 `shop` 만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n shop delete httproute shop-route --ignore-not-found 2>/dev/null || true
kubectl -n shop delete svc catalog cart --ignore-not-found 2>/dev/null || true
kubectl -n shop delete deploy catalog cart --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n infra delete gateway main-gw --ignore-not-found 2>/dev/null || true
# NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 남겨 둔다

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-e08=created) 남은 리소스가 없을 때만 지운다
for ns in shop infra; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-e08}' 2>/dev/null || true)" = "created" ] || continue
  left=$( { kubectl -n "$ns" get all,configmap,secret,ingress,pvc,networkpolicy -o name 2>/dev/null
            kubectl -n "$ns" get gateway,httproute -o name 2>/dev/null; } \
          | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
done
```

</details>

## Task

Gateway `main-gw` in namespace `infra` has a listener named `http` (HTTP, port 80) that accepts
routes from all namespaces. Namespace `shop` contains Service `catalog` (port 80) and Service
`cart` (port 8080). Both backends answer any path with a short text that contains their own name.

1. Create an HTTPRoute named `shop-route` in namespace `shop`, attached to listener `http` of
   Gateway `main-gw`, for hostname `shop.example.com`.
2. Requests with path prefix `/cart` must go to Service `cart` on port `8080`; all other requests
   (prefix `/`) must go to Service `catalog` on port `80`.
3. Confirm that the Gateway accepted the route, and test both paths with `curl` using the header
   `Host: shop.example.com`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
