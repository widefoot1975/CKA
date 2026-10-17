# q08 — Expose a service with the Gateway API

| Item | Value |
|---|---|
| Exam | mock_exam_b |
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
#    NGF 가 CRD 없이는 뜨지 않아 CRD 도 함께 깐다. 문제 1번은 "설치돼 있는지 확인"하는 단계가 된다.
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v2.7.2/deploy/nodeport/deploy.yaml
kubectl -n nginx-gateway rollout status deploy nginx-gateway --timeout=180s

# 2) 이전 실습 흔적 정리 (namespace gw 와 백엔드는 문제에서 직접 만든다)
kubectl delete ns gw --ignore-not-found --wait=true
rm -rf /opt/q08

# 3) 답안 파일 디렉터리
mkdir -p /opt/q08

# 4) 시작 상태 확인: GatewayClass nginx ACCEPTED True, namespace gw 없음
kubectl get gatewayclass nginx
kubectl get ns gw 2>/dev/null || echo "namespace gw 없음 (정상)"
ls -ld /opt/q08
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 GatewayClass `nginx` 는 `Accepted` 이고 Gateway API standard CRD 가 깔려 있다. 1번은 버전·채널을 읽어 적는 확인 단계다.
namespace `gw` 와 Deployment·Service·Gateway·HTTPRoute 는 없다. 2~4번에서 직접 만든다(namespace 도 직접 만든다).
NGINX Gateway Fabric 은 Gateway 마다 같은 네임스페이스에 데이터 플레인 Service(`main-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `gw` 와 `/opt/q08` 만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns gw --ignore-not-found
rm -rf /opt/q08
```

</details>

## Task

The cluster has an NGINX Gateway controller installed, registered as GatewayClass `nginx`.

1. Make sure the Gateway API **standard** CRDs are installed at a version the controller
   supports (install them if missing), confirm `gateway.networking.k8s.io/v1` is served and
   that GatewayClass `nginx` is `Accepted`, and write the installed bundle version and
   channel to `/opt/q08/gateway-api.txt`.
2. In namespace `gw`, create deployment/service `shop-svc` (`nginx:1.27`, service port
   `80`) and deployment/service `api-svc` (`nginx:1.27`, service port `8080` to container
   port `80`).
3. Create a `Gateway` named `main-gw` in `gw` using gatewayClassName `nginx`, with one
   listener named `http`, protocol `HTTP`, port `80`, accepting HTTPRoutes **from all
   namespaces**.
4. Create an `HTTPRoute` named `store-route` in `gw` attached to `main-gw`, for hostname
   `store.example.com`, routing `PathPrefix` `/api` to `api-svc:8080` and `PathPrefix`
   `/` to `shop-svc:80`.
5. Confirm the Gateway listener is `Programmed` and that the HTTPRoute reports
   `Accepted=True` and `ResolvedRefs=True`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
