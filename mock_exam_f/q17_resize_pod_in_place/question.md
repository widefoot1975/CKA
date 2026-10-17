# q17 — Give a running Pod more memory without restarting it

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
클러스터가 v1.33 이상이어야 한다(in-place resize 는 v1.33 beta 기본 활성, v1.35 GA).

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q17_resize_pod_in_place
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `cache` 는 QoS `Burstable`, RESTARTS `0` 으로 보인다. `kubectl top` 이 아직
`metrics not available yet` 을 내면 1분쯤 뒤에 다시 본다.

## Task

In namespace `perf`, the standalone Pod `cache` (container `app`, image `nginx:1.27`) runs
with a memory request of `64Mi` and a memory limit of `128Mi`. It is healthy but needs
more memory headroom, and it must not be restarted or recreated. metrics-server is
installed.

1. Write the current memory usage of container `app`, as reported by `kubectl top`, to
   `/opt/course/f17/usage.txt`.
2. Raise the memory request of `app` to `128Mi` and its memory limit to `256Mi` without
   deleting, recreating or restarting the Pod.
3. Verify that the Pod status reports the new memory request and limit for `app` and that
   the container's `restartCount` did not change.

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

[↑ 문항 목록](../README.md) · [← q16](../q16_multicontainer_logs_prefix/question.md)
