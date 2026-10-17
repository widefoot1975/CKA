# q08 — Expose a Service through the Gateway API

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `web` 은 A06·A09·B05·F06 도 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다. `mock_exam_b/q05` 도 `web` 에 Deployment `frontend` 를 만들므로 두 문제를 동시에 펼쳐 두지 않는다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 1) Gateway API CRD + NGINX Gateway Fabric (GatewayClass nginx, 데이터 플레인은 NodePort)
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 (이 문제가 만드는 오브젝트만)
kubectl -n web delete httproute frontend-route --ignore-not-found 2>/dev/null || true
kubectl -n web delete gateway web-gw --ignore-not-found 2>/dev/null || true
kubectl -n web delete svc frontend --ignore-not-found 2>/dev/null || true
kubectl -n web delete deploy frontend --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true

# 3) namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns web >/dev/null 2>&1; then
  kubectl create ns web
  kubectl label ns web cka-lab-d08=created --overwrite
fi
#    Deployment/Service frontend
kubectl -n web create deploy frontend --image=nginx:1.27
kubectl -n web expose deploy frontend --port=80
kubectl -n web rollout status deploy frontend

# 4) 시작 상태 확인: GatewayClass nginx ACCEPTED True, web 에는 Gateway/HTTPRoute 없음
kubectl get gatewayclass nginx
kubectl -n web get deploy,svc,gateway,httproute
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `web` 에는 Deployment·Service `frontend` 만 있고 Gateway 와 HTTPRoute 는 없다. 문제 풀이에서 직접 만든다.
NGINX Gateway Fabric 은 Gateway 마다 `web` 안에 데이터 플레인 Service(`web-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `web` 만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n web delete httproute frontend-route --ignore-not-found 2>/dev/null || true
kubectl -n web delete gateway web-gw --ignore-not-found 2>/dev/null || true
kubectl -n web delete svc frontend --ignore-not-found 2>/dev/null || true
kubectl -n web delete deploy frontend --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
# NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 남겨 둔다

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-d08=created) 남은 리소스가 없을 때만 지운다
for ns in web; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-d08}' 2>/dev/null || true)" = "created" ] || continue
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

GatewayClass `nginx` is installed and `Accepted`. Namespace `web` contains Deployment
`frontend` and Service `frontend` (port 80).

1. Create a Gateway `web-gw` in `web` with gatewayClassName `nginx` and a single listener named
   `http`: protocol `HTTP`, port `80`.
2. Create an HTTPRoute `frontend-route` in `web`, attached to the `http` listener of `web-gw`,
   for hostname `shop.example.com`, that sends path prefix `/` to Service `frontend` on port 80.
3. Verify that the Gateway is `Programmed`, that the route reports `Accepted=True` and
   `ResolvedRefs=True`, and that an HTTP request to the Gateway address with host
   `shop.example.com` returns the frontend page.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
