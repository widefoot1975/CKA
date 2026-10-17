# q14 — A container is being OOMKilled

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q14_oomkilled_resource_analysis
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `resizer` 파드는 RESTARTS 가 계속 늘고(`lastState.terminated.reason: OOMKilled`), `cache-warm` 은 `1/1 Running` 이다.
5번의 in-place resize 는 v1.33 이상(1.35 GA)과 kubectl 1.32 이상이 필요하다. 이미지 `polinux/stress` 를 받을 수 있어야 한다.

## Task

In namespace `prod`, Deployment `resizer` keeps restarting. `kubectl get pods` shows a
climbing `RESTARTS` count and the pod flips between `Running` and `CrashLoopBackOff`. The
image is known good; in staging the team measured a peak of about 180Mi.

1. Confirm the container is being killed for memory and not crashing on its own. State
   which field you read and what exit code you expect.
2. Report the container's current memory request and limit and its actual usage, and
   explain in one line why it was killed even though the node has free memory.
3. Set the container's memory request to `128Mi` and limit to `256Mi` on the Deployment,
   and confirm the restarts stop.
4. Write the Pod's QoS class before and after your change to `/opt/course/q14/qos.txt`,
   and state what else the container would need to become `Guaranteed`.
5. The standalone Pod `cache-warm` in `prod` (container `cache`) is healthy with a `64Mi`
   memory limit but needs more headroom before tonight's load test. Raise its memory
   request to `128Mi` and limit to `256Mi` **without deleting, recreating or restarting
   the Pod**, and show that the new values are in effect and its restart count did not
   change.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_coredns_resolution_failure/question.md) · [q15 →](../q15_multicontainer_sidecar_logs/question.md)
