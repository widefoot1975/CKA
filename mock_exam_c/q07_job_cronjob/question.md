# q07 — Run work with a Job and a CronJob

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

All work goes in namespace `batch`.

1. Create a Job `migrate` using `busybox:1.36` that runs
   `sh -c 'echo migrating; sleep 5; echo done'`. It must complete 4 times, with at most
   2 pods running at once, give up after 3 failed attempts, and be killed if the whole
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
