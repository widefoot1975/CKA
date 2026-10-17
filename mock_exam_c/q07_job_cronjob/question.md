# q07 — Run work with a Job and a CronJob

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `batch` 는 mock_exam_d/q17 도 쓰므로, 설정과 정리는 namespace 를 통째로 지우지 않고 이 문제의 Job·CronJob 만 지운다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q07_job_cronjob
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `batch` 가 있고, 그 안에 `migrate`·`broken`·`report` 가 없다(`No resources found`, 또는 다른 문제의 리소스만 보임).
CronJob `report` 는 suspend 하기 전까지 5분마다 Job 을 만들므로 실습이 끝나면 정리한다. 이미지 `busybox:1.36` 을 받을 수 있어야 한다.

## Task

All work goes in namespace `batch`.

1. Create a Job `migrate` using `busybox:1.36` that runs
   `sh -c 'echo migrating; sleep 5; echo done'`. It must complete 4 times, with at most
   2 pods running at once, retry failed pods at most 3 times, and be killed if the whole
   Job exceeds 120 seconds.
2. Create a Job `broken` that runs `sh -c 'exit 1'` with `backoffLimit: 2`. Show its
   final status and how many pods it created.
3. Create a CronJob `report` running `busybox:1.36` with
   `sh -c 'date; echo report'` every 5 minutes. Keep 3 successful and 1 failed job in
   history, forbid concurrent runs, and mark a run failed if it has not started within
   30 seconds of its schedule.
4. Trigger `report` immediately without waiting for the schedule, and show the output of
   that run.
5. Suspend the CronJob afterwards.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_probes_pod_disruption_budget/question.md) · [q08 →](../q08_httproute_traffic_split/question.md)
