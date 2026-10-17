# q06 — Constrain a namespace with ResourceQuota and LimitRange

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q06_resourcequota_limitrange
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

namespace `team-a` 는 문제 1번에서 직접 만들어야 하므로 setup 은 지우기만 하고, 답안 디렉터리 `/opt/q06/` 만 만든다.

## Task

Namespace `team-a` must be capped, and its users must not have to write resource fields
by hand.

1. Create namespace `team-a` and a ResourceQuota named `team-a-quota` with
   `requests.cpu: "1"`, `requests.memory: 1Gi`, `limits.cpu: "2"`,
   `limits.memory: 2Gi`, `pods: "10"`, `configmaps: "5"`.
2. Try to create a pod named `probe` with image `nginx:1.27` and **no** resource fields.
   Write the exact rejection message to `/opt/q06/rejected.txt`.
3. Create a LimitRange named `team-a-defaults` for `Container` with
   `defaultRequest` cpu `100m` / memory `128Mi`, `default` cpu `200m` /
   memory `256Mi`, and `max` cpu `500m`.
4. Create `probe` again, still with no resource fields, and show the values it was given.
5. Show the quota's used-versus-hard figures and confirm `requests.cpu` used is `100m`.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_hpa_workload_autoscaling/question.md) · [q07 →](../q07_priorityclass_preemption/question.md)
