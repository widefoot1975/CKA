# q05 — Autoscale a Deployment with an HPA

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q05_hpa_behavior
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 Deployment `apache-web` 은 CPU request `100m` 을 가지고 HPA 는 없다. metrics-server 가 값을 모으기까지 1분 정도 걸릴 수 있다.
`cleanup.sh` 는 metrics-server 를 남겨 둔다(`kubectl top` 등 다른 문제에서도 쓰임).

## Task

Deployment `apache-web` in namespace `autoscale` runs `httpd:2.4`, and its container already
requests `100m` CPU. metrics-server is installed.

1. Create a HorizontalPodAutoscaler named `apache-web` in namespace `autoscale` with API version
   `autoscaling/v2`. It targets Deployment `apache-web` with `minReplicas: 1`, `maxReplicas: 4`
   and a target average CPU utilization of `50%`.
2. When scaling down, the HPA must use a stabilization window of `30` seconds.
3. Confirm that the HPA reports an actual CPU percentage instead of `<unknown>`.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_ha_control_plane_inspect/question.md) · [q06 →](../q06_resource_requests_all_containers/question.md)
