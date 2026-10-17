# q06 — Set resources on every container, including init

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
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q06_resource_requests_all_containers
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 파드 2개가 Running 이고, 두 컨테이너의 resources 는 `{}` 로 비어 있다.

## Task

Deployment `wordpress` in namespace `wp` has an init container `init-perms` and an app container
`wordpress`. Neither of them has resource requests or limits.

1. Scale Deployment `wordpress` to `0` replicas before you change it.
2. Set exactly these resources on **both** the init container `init-perms` and the container
   `wordpress`: requests `cpu: 250m`, `memory: 256Mi`; limits `cpu: 500m`, `memory: 512Mi`.
3. Scale the Deployment to `3` replicas. Confirm that all 3 pods are `Running` and ready, and that
   both containers in the pod template carry the new resources.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_hpa_behavior/question.md) · [q07 →](../q07_native_sidecar_log_shipper/question.md)
