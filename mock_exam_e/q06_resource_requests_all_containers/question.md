# q06 — Set resources on every container, including init

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Deployment `wordpress` in namespace `wp` has an init container `init-perms` and an app container
`wordpress`. Neither of them has resource requests or limits.

1. Scale Deployment `wordpress` to `0` replicas before you change it.
2. Set exactly these resources on **both** the init container `init-perms` and the container
   `wordpress`: requests `cpu: 250m`, `memory: 256Mi`; limits `cpu: 500m`, `memory: 512Mi`.
3. Scale the Deployment to `3` replicas. Confirm that all 3 pods are `Running` and ready, and that
   both containers in the pod template carry the new resources.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
