# q05 — Deployment rolling update and rollback

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 6 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In the `web` namespace, do the following.

1. Create a Deployment named `frontend` with image `nginx:1.25` and 4 replicas.
2. Configure the update strategy so that **at most 1 pod is unavailable and at most 1
   extra pod is created** during an update.
3. Update the image to `nginx:1.26` and check the rollout status.
4. Update once more to the non-existent tag `nginx:9.9.9`, confirm the rollout stalls,
   then **roll back to the last working revision**.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
