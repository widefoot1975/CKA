# q15 — Fix a crash-looping Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Deployment `worker` in namespace `jobs` (1 replica, image `busybox:1.36`) is in
`CrashLoopBackOff`. Its container `worker` is supposed to print a start message and then run
`sleep 3600`.

1. Write the logs of the **previous** (crashed) instance of container `worker` to
   `/opt/course/e15/previous.log`.
2. Write the exit code of that container's last termination to `/opt/course/e15/exitcode.txt`.
3. Fix the Deployment so that the container keeps running. Do not change the image.
4. Confirm that the new pod is `Running` and that its restart count does not increase any more.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
