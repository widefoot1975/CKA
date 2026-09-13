# q02 — Upgrade the cluster lifecycle with kubeadm

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c2` + ssh to the nodes |
| Target time | 13 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The cluster runs v1.34. Bring it to v1.35.

1. Show which versions kubeadm can upgrade this cluster to, **before** changing anything.
2. Upgrade the control plane node `cp01`, including `kubelet` and `kubectl`.
3. Upgrade the worker node `worker01`.
4. Each node must be drained before its kubelet is replaced and made schedulable again
   afterwards.
5. Confirm every node reports v1.35 and is `Ready`, and that no control plane component
   is failing.

State in one line why the worker uses a different kubeadm subcommand than the control
plane.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
