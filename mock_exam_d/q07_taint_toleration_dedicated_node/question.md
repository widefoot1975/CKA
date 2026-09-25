# q07 — Dedicate a node with a taint and a toleration

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

Node `worker02` is to be reserved for GPU workloads: other pods must stay off it, and GPU pods
must land on it.

1. Taint node `worker02` with `dedicated=gpu:NoSchedule` and add the label `accelerator=gpu`
   to it.
2. Create pod `gpu-job` in namespace `default` (image `nginx:1.27`) that tolerates this taint
   and has the `nodeSelector` `accelerator: gpu`. Confirm it is running on `worker02`.
3. Create pod `plain` in `default` (image `nginx:1.27`) with the same `nodeSelector` but without
   the toleration. Confirm it stays `Pending` and that its scheduling event mentions the
   untolerated taint.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
