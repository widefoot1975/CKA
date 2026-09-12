# q06 — Scheduling with taints, tolerations and node affinity

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

1. Label node `worker01` with `disktype=ssd` and taint it with `gpu=true:NoSchedule`.
2. Create a pod named `gpu-workload` using image `nginx` that
   - **tolerates** the `gpu=true:NoSchedule` taint, and
   - is scheduled **only** onto nodes labelled `disktype=ssd` (a hard requirement,
     not a preference).
3. Create a pod named `plain-workload` with the same image and no toleration.
4. Confirm `gpu-workload` lands on `worker01` and `plain-workload` does not.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
