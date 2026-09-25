# q05 — Scale, update and roll back a Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `shop` contains Deployment `web` (image `nginx:1.27`, 2 replicas).

1. Scale `web` to 4 replicas.
2. Update the image of its container to `nginx:1.28` and record the change cause
   `upgrade to 1.28` on the Deployment so that it appears in the rollout history.
3. Roll `web` back to the previous revision.
4. Confirm that `web` runs image `nginx:1.27` again with 4 ready replicas.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
