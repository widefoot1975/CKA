# q03 — Install a CNI plugin that enforces NetworkPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c4` (→ `ssh <node>` if needed) |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Cluster `k8s-c4` was just built with kubeadm. Every node is `NotReady` and the CoreDNS
pods are `Pending`. Two sets of CNI manifests are staged on the task host:

- `/opt/course/q03/flannel/kube-flannel.yml`
- `/opt/course/q03/calico/` — the Calico operator manifests and `custom-resources.yaml`

1. Find the pod CIDR the cluster was initialised with and write it to
   `/opt/course/q03/podcidr.txt`.
2. Install the one CNI that satisfies **both** requirements: pods on different nodes can
   reach each other, **and** NetworkPolicy is enforced. Use only the staged manifests (no
   Helm), and make its IP pool match the cluster's pod CIDR.
3. Confirm every node is `Ready`, the CoreDNS pods are `Running`, and a CNI configuration
   file exists under `/etc/cni/net.d/` on a worker node.
4. Prove pod-to-pod connectivity across nodes with two test pods pinned to different
   nodes in namespace `cni-test`.
5. Prove enforcement: after a default-deny ingress policy is applied in `cni-test`, the
   same request must fail.
6. State in one line why the other staged CNI would not satisfy the task.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
