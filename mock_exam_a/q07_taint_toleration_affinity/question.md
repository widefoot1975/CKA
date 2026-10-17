# q07 — Place pods with taints, tolerations and node affinity

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q07_taint_toleration_affinity
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `worker02` 에는 `workload` taint 와 `tier` 라벨이 없고, `tier=web` 라벨이 붙은 노드도 없다.
taint 와 라벨은 문제 풀이 1단계에서 직접 붙인다. `tier=web` 노드가 없는 상태라야 3단계의 "선호 노드가 없어도 스케줄된다"를 확인할 수 있다.
taint 를 그대로 두면 다른 문제의 파드가 `worker02` 에 올라가지 못하므로 실습이 끝나면 꼭 정리한다.

## Task

Batch jobs must be kept off the general worker pool and confined to one dedicated node.

1. Taint node `worker02` with `workload=batch:NoSchedule` and label it `tier=batch`.
2. Create a Pod `batch-runner` in `default` running `busybox:1.36` with command
   `sleep 3600`, which tolerates that taint and can be scheduled **only** onto nodes
   labelled `tier=batch`. Use node affinity, not `nodeSelector`.
3. Create a Pod `web-front` running `nginx:1.27` that prefers nodes labelled `tier=web`
   with weight 50 but must still schedule when no such node exists.
4. Confirm where each pod landed, then state in one line why giving `batch-runner` only
   the toleration would not have been enough.
5. Remove the taint from `worker02` and show it is gone.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_configmap_secret_injection/question.md) · [q08 →](../q08_service_types_endpoints/question.md)
