# q14 — Gateway accepts traffic but nothing reaches the backend

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q14_gateway_traffic_not_routed
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q13](../q13_metrics_server_resource_usage/question.md) · [q15 →](../q15_cni_pod_containercreating/question.md)
