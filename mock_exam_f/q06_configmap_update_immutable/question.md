# q06 — Update configuration and lock it

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

In namespace `web`, Deployment `api` (image `nginx:1.27`) loads all keys of ConfigMap
`app-config` as environment variables through `envFrom`. The ConfigMap currently contains
`LOG_LEVEL=debug`.

1. Change `LOG_LEVEL` in ConfigMap `app-config` to `info`.
2. Make ConfigMap `app-config` immutable so that its data can no longer be changed.
3. Make the Pods of Deployment `api` use the new value without deleting the Deployment,
   and verify with `kubectl exec` that `LOG_LEVEL=info` is set in a running Pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
