# q08 — Weighted traffic splitting with HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q08_httproute_traffic_split
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `gateway-system` 에는 Gateway `web-gw` 가, `shop` 에는 Deployment `shop-v1`·`shop-v2` 만 있고 Service 와 HTTPRoute 는 없다. 문제 풀이에서 직접 만든다.
두 Deployment 는 `nginx:1.27`(컨테이너 포트 80)이고, 비율을 눈으로 셀 수 있도록 어떤 경로든 `shop-v1` / `shop-v2` 를 돌려주게 nginx 설정만 바꿨다.
NGINX Gateway Fabric 은 `gateway-system` 안에 데이터 플레인 Service(`web-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `gateway-system` 과 `shop` 만 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q07](../q07_job_cronjob/question.md) · [q09 →](../q09_ingress_to_gateway_migration/question.md)
