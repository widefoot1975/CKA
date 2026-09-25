# q07 — Schedule and trigger a CronJob

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

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

---

Solution → **[solution.md](solution.md)**
