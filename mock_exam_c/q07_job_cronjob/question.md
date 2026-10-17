# q07 — Run work with a Job and a CronJob

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `batch` 는 mock_exam_d/q17 도 쓰므로, 설정과 정리는 namespace 를 통째로 지우지 않고 이 문제의 Job·CronJob 만 지운다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (CronJob report 를 지우면 그 아래 Job 도 함께 지워진다)
kubectl -n batch delete cronjob report --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n batch delete job migrate broken report-manual --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true

# 1) 작업할 namespace (없을 때만 만들고, 이 문제가 만든 것이라는 표시를 붙인다)
if ! kubectl get ns batch >/dev/null 2>&1; then
  kubectl create ns batch
  kubectl label ns batch cka-practice=c07
fi

# 2) 설정 확인: batch 에 이 문제의 Job·CronJob 이 없어야 함
kubectl get ns batch
kubectl -n batch get cronjob,job
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `batch` 가 있고, 그 안에 `migrate`·`broken`·`report` 가 없다(`No resources found`, 또는 다른 문제의 리소스만 보임).
CronJob `report` 는 suspend 하기 전까지 5분마다 Job 을 만들므로 실습이 끝나면 정리한다. 이미지 `busybox:1.36` 을 받을 수 있어야 한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n batch delete cronjob report --ignore-not-found --cascade=foreground --wait=true
kubectl -n batch delete job migrate broken report-manual --ignore-not-found --cascade=foreground --wait=true
# setup 이 만든 namespace 이고 남은 리소스가 없을 때만 namespace 삭제
if [ "$(kubectl get ns batch -o jsonpath='{.metadata.labels.cka-practice}' 2>/dev/null || true)" = "c07" ] \
   && [ -z "$(kubectl -n batch get pods,jobs,cronjobs,deploy,sts,ds -o name 2>/dev/null)" ]; then
  kubectl delete ns batch --ignore-not-found
fi
```

</details>

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

---

Solution → **[solution.md](solution.md)**
