# q07 — Place pods with taints, tolerations and node affinity

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Batch jobs must be kept off the general worker pool and confined to one dedicated node.

1. Taint node `worker02` with `workload=batch:NoSchedule` and label it `tier=batch`.
2. Create a Pod `batch-runner` in `default` running `busybox:1.36` with command
   `sleep 3600`, which tolerates that taint and can be scheduled **only** onto nodes
   labelled `tier=batch`. Use node affinity, not `nodeSelector`.
3. Create a Pod `web-front` running `nginx:1.27` that prefers nodes labelled `tier=web`
   with weight 50 but must still schedule when no such node exists.
4. Confirm where each pod landed, then state in one line why giving `batch-runner` only
   the toleration would not have been enough.
5. Remove the taint from `worker02` and show it is gone.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
