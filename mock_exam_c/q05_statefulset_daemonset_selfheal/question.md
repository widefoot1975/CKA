# q05 — Self-healing with StatefulSet and DaemonSet

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `infra` 는 다른 문제(mock_exam_e q08)도 쓰므로 namespace 는 지우지 않고 이 문제의 객체만 정리한다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q05_statefulset_daemonset_selfheal
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `infra` 에는 헤드리스 Service `cache`(`CLUSTER-IP None`, selector `app=cache`)만 있고 DaemonSet·StatefulSet 은 없다.
노드가 2개 이상(컨트롤 플레인 1 + 워커 1 이상)이어야 1·4번을 제대로 확인할 수 있다. 이미지 `busybox:1.36`, `redis:7.2` 를 받을 수 있어야 한다.

## Task

In namespace `infra`:

1. Create a DaemonSet `node-agent` running `busybox:1.36` with the command
   `sh -c 'while true; do sleep 30; done'`. It must run on **every** node including
   control plane nodes.
2. Create a StatefulSet `cache` with 3 replicas of `redis:7.2`, governed by an existing
   headless Service named `cache`, container port 6379.
3. Delete the pod `cache-1` and record what the controller recreates — the pod name and
   whether the ordinal is preserved.
4. Delete the `node-agent` pod on one worker node and record how quickly it returns.
5. In one line each, state which object the DaemonSet controller reconciles against and
   what the StatefulSet guarantees that a Deployment does not.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_operator_install_configure/question.md) · [q06 →](../q06_probes_pod_disruption_budget/question.md)
