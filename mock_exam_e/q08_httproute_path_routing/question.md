# q08 — Route two paths with one HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `infra` 는 C05 가, `shop` 은 A08·A15·C06·C08·D05·F15 가 함께 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다. `mock_exam_c/q08` 도 `shop` 에 HTTPRoute `shop-route` 를 만들므로 두 문제를 동시에 펼쳐 두지 않는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q08_httproute_path_routing
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `infra` 에는 Gateway `main-gw` 가, `shop` 에는 Deployment·Service `catalog`(80)와 `cart`(8080)가 있고 HTTPRoute 는 없다. 문제 풀이에서 직접 만든다.
NGINX Gateway Fabric 은 `infra` 안에 데이터 플레인 Service(`main-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `infra` 와 `shop` 만 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q07](../q07_native_sidecar_log_shipper/question.md) · [q09 →](../q09_ingress_path_basic/question.md)
