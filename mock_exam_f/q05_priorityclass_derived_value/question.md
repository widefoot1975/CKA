# q05 — Create a PriorityClass relative to existing ones

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

Deployment `busybox-logger` in namespace `priority` needs a high priority, just below the
most important existing user workload. Several user-defined PriorityClasses already exist
in the cluster.

1. Find the highest `value` among the existing user-defined PriorityClasses (ignore the
   built-in `system-*` classes). Create PriorityClass `high-priority` with a value exactly
   one less than that. It must not be the global default.
2. Patch Deployment `busybox-logger` in namespace `priority` so that its Pods use
   PriorityClass `high-priority`.
3. Confirm that the Deployment's new Pods have `spec.priority` equal to the value of
   `high-priority`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
