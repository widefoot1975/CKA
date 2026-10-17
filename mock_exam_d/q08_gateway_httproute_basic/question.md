# q08 — Expose a Service through the Gateway API

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `web` 은 A06·A09·B05·F06 도 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다. `mock_exam_b/q05` 도 `web` 에 Deployment `frontend` 를 만들므로 두 문제를 동시에 펼쳐 두지 않는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q08_gateway_httproute_basic
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `web` 에는 Deployment·Service `frontend` 만 있고 Gateway 와 HTTPRoute 는 없다. 문제 풀이에서 직접 만든다.
NGINX Gateway Fabric 은 Gateway 마다 `web` 안에 데이터 플레인 Service(`web-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `web` 만 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q07](../q07_taint_toleration_dedicated_node/question.md) · [q09 →](../q09_nodeport_expose_container_port/question.md)
