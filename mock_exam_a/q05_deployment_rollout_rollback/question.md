# q05 — Rolling update, pause and roll back a Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `apps` serves a web tier that must never drop below its declared capacity
during an update.

1. Create a Deployment `web` in `apps` with 4 replicas of `nginx:1.25`, then set its
   strategy to `RollingUpdate` with `maxSurge: 1` and `maxUnavailable: 0`.
2. Roll it out to `nginx:1.26` and make `bump to 1.26` appear as the change cause in the
   rollout history.
3. Pause the rollout, change the image to `nginx:1.27`, and show that no new ReplicaSet is
   scaled up while paused. Then resume and wait for the rollout to finish.
4. Print the revision history, inspect revision 1, then roll back to the revision running
   `nginx:1.25`.
5. Confirm the running image and that the rollout is complete.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
