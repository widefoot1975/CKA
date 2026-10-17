# q08 — Expose a service with the Gateway API

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q08_gateway_api_httproute
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 GatewayClass `nginx` 는 `Accepted` 이고 Gateway API standard CRD 가 깔려 있다. 1번은 버전·채널을 읽어 적는 확인 단계다.
namespace `gw` 와 Deployment·Service·Gateway·HTTPRoute 는 없다. 2~4번에서 직접 만든다(namespace 도 직접 만든다).
NGINX Gateway Fabric 은 Gateway 마다 같은 네임스페이스에 데이터 플레인 Service(`main-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `gw` 와 `/opt/q08` 만 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q07](../q07_priorityclass_preemption/question.md) · [q09 →](../q09_networkpolicy_ingress_egress/question.md)
