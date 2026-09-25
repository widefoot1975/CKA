# q17 — Give a running Pod more memory without restarting it

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

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

---

Solution → **[solution.md](solution.md)**
