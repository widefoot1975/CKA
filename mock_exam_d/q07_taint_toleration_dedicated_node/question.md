# q07 — Dedicate a node with a taint and a toleration

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q07_taint_toleration_dedicated_node
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `worker02` 에는 taint 와 `accelerator` 라벨이 없다. 문제 풀이에서 직접 붙인다.
taint 를 그대로 두면 다른 문제의 파드가 `worker02` 에 올라가지 못하므로 실습이 끝나면 꼭 정리한다.

## Task

Node `worker02` is to be reserved for GPU workloads: other pods must stay off it, and GPU pods
must land on it.

1. Taint node `worker02` with `dedicated=gpu:NoSchedule` and add the label `accelerator=gpu`
   to it.
2. Create pod `gpu-job` in namespace `default` (image `nginx:1.27`) that tolerates this taint
   and has the `nodeSelector` `accelerator: gpu`. Confirm it is running on `worker02`.
3. Create pod `plain` in `default` (image `nginx:1.27`) with the same `nodeSelector` but without
   the toleration. Confirm it stays `Pending` and that its scheduling event mentions the
   untolerated taint.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_configmap_env_and_volume/question.md) · [q08 →](../q08_gateway_httproute_basic/question.md)
