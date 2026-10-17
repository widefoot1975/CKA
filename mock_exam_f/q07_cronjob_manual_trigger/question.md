# q07 — Schedule and trigger a CronJob

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
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q07_cronjob_manual_trigger
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `ops` 에 CronJob·Job 이 없고(`No resources found`), `/opt/course/f07/` 디렉터리가 있다.
namespace `ops` 는 A11·A12 도 쓰므로 setup·cleanup 은 이 문제의 CronJob·Job 만 지우고, namespace 는 이 setup 이 만들었고 비어 있을 때만 지운다.
CronJob 은 10분마다 Job 을 만들므로 실습이 끝나면 정리한다.

## Task

Namespace `ops` already exists.

1. Create CronJob `cleanup` in namespace `ops` that runs image `busybox:1.36` with the
   command `sh -c 'date; echo cleanup done'` every 10 minutes. It must keep `2` successful
   and `1` failed Job in its history, and it must never start a new run while the
   previous run is still active.
2. Without waiting for the schedule, run the CronJob now as a Job named `cleanup-manual`.
3. Write the log output of Job `cleanup-manual` to `/opt/course/f07/run.log`.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_configmap_update_immutable/question.md) · [q08 →](../q08_ingress_to_httproute_simple/question.md)
