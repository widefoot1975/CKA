# q03 — Upgrade one worker node with kubeadm

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c2` → `ssh worker01`, then `sudo -i` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The control plane of cluster `k8s-c2` already runs Kubernetes v1.35.x, but node `worker01`
still runs v1.34. On `worker01` the apt repository already points to the Kubernetes v1.35
packages and `apt update` has already been run. Run `kubectl` commands from `k8s-c2`.

1. On `worker01`, upgrade `kubeadm` to exactly the version the control plane runs, then
   run the `kubeadm` upgrade step for a worker node.
2. Drain `worker01`. Then upgrade `kubelet` and `kubectl` on `worker01` to the same
   version and restart the kubelet.
3. Make `worker01` schedulable again and confirm that `kubectl get nodes` shows it `Ready`
   with the new version.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
