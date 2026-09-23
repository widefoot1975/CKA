# q02 — Upgrade the cluster lifecycle with kubeadm

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c2` → `ssh cp01` / `ssh worker01`, then `sudo -i` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The cluster runs v1.34. Bring it to v1.35.

1. **Before** applying any upgrade, show the upgrade plan kubeadm proposes for v1.35.
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
