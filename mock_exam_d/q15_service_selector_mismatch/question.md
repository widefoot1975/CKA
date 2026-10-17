# q15 — A Service with no endpoints

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q15_service_selector_mismatch
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `store` 에는 Ready 인 `catalog` 파드 2개(라벨 `app=catalog`)와 Service `catalog` 가 있고, EndpointSlice 의 ENDPOINTS 는 비어 있다.

## Task

In namespace `store`, requests to Service `catalog` (port 80) fail. Deployment `catalog`
(2 replicas, image `nginx:1.27`) is running and its pods are `Ready`.

1. Show that the Service has no endpoints by looking at its EndpointSlice.
2. Find the reason by comparing the Service's selector with the labels of the `catalog` pods.
3. Fix the Service so that it selects the `catalog` pods. Do not change the Deployment or the
   pods.
4. Confirm that the EndpointSlice now lists 2 pod addresses.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_scheduler_static_pod_image/question.md) · [q16 →](../q16_sidecar_container_logs/question.md)
