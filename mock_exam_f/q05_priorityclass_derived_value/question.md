# q05 — Create a PriorityClass relative to existing ones

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q05_priorityclass_derived_value
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 파드는 `default-workload` / `10000` 으로 보인다(global default 클래스가 자동 적용됨).
`default-workload` 는 globalDefault 라서 클러스터의 다른 새 파드에도 붙으므로, 실습이 끝나면 꼭 정리한다.

## Task

Deployment `busybox-logger` in namespace `priority` needs a high priority, just below the
most important existing user workload. Several user-defined PriorityClasses already exist
in the cluster.

1. Find the highest `value` among the existing user-defined PriorityClasses (ignore the
   built-in `system-*` classes). Create PriorityClass `high-priority` with a value exactly
   one less than that. It must not be the global default.
2. Patch Deployment `busybox-logger` in namespace `priority` so that its Pods use
   PriorityClass `high-priority`.
3. Confirm that the Deployment's new Pods have `spec.priority` equal to the value of
   `high-priority`.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_extension_interfaces_inventory/question.md) · [q06 →](../q06_configmap_update_immutable/question.md)
