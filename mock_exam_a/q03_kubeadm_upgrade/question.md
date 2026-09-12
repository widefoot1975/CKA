# q03 — Upgrade a kubeadm cluster

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c2` + ssh to the nodes |
| Target time | 12 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Upgrade the cluster by one minor version (for example v1.34 → v1.35).

1. Upgrade the control plane node `cp01` first. Upgrade **kubelet and kubectl as well**.
2. Then upgrade the worker node `worker01`.
3. Drain each node before upgrading it and make it schedulable again afterwards.
4. Confirm every node reports the target version and is `Ready`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
