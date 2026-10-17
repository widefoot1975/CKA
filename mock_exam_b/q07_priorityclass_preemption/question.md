# q07 — Pod priority and preemption

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
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q07_priorityclass_preemption
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `sched` 는 비어 있고, `system-*` 를 뺀 사용자 정의 PriorityClass 는 `team-batch` · `ml-training` · `zz-observer` · `ops-urgent` 네 개다.
PriorityClass 는 클러스터 범위라 다른 문제(`mock_exam_f/q05` 등)의 클래스가 함께 있으면 기준 최댓값이 달라진다. 이 문제만 펼쳐 두고 푼다.
`filler` 가 워커 CPU 를 꽉 채우므로, 실습이 끝나면 꼭 정리한다.

## Task

Namespace `sched` runs batch filler work that must yield to payment processing. Other
teams have already created user-defined PriorityClasses in this cluster, all with values
above `10000`.

1. Create three PriorityClasses, none of them `globalDefault`:
   - `critical-priority`, description `payment path`, whose value is **one less than the
     highest user-defined PriorityClass that already exists** (ignore the built-in
     `system-*` classes)
   - `low-priority`, value `1000`
   - `queue-jumper`, value `50000`, which must **never** evict another pod
2. In `sched`, create deployment `filler` with image `nginx:1.27`, priority class
   `low-priority` and each container requesting `cpu: 400m`, with enough replicas that the
   cluster's allocatable CPU is exhausted and at least one replica stays `Pending`.
3. Create pod `payment` in `sched` with image `nginx:1.27`, priority class
   `critical-priority`, requesting `cpu: 500m`.
4. Show that `payment` becomes scheduled and that a `filler` pod was preempted. Write the
   event message naming the preemptor to `/opt/q07/preempt.txt`.
5. Write to `/opt/q07/never.txt` what `queue-jumper` still gains from its high value,
   given that it cannot preempt.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_resourcequota_limitrange/question.md) · [q08 →](../q08_gateway_api_httproute/question.md)
