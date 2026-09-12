# q04 — Node maintenance with drain and uncordon

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 5 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Node `worker02` must be emptied for maintenance.

1. Move the running pods off `worker02` and stop new pods from being scheduled there.
2. Make sure DaemonSet pods do not block the command.
3. If the command is refused because a pod uses `emptyDir`, allow that too.
4. Assume maintenance is finished and return the node to normal service.
5. Additionally, add the taint `maintenance=true:NoSchedule` to `worker02`, then remove it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
