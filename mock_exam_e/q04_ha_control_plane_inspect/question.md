# q04 — Inspect a highly-available control plane

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c3` → `ssh cp01`, then `sudo -i` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Cluster `k8s-c3` runs a stacked highly-available control plane (etcd runs on every control plane
node) with three control plane nodes. Nothing is broken; you only need to collect facts.

1. Write the `controlPlaneEndpoint` value from ConfigMap `kubeadm-config` in namespace
   `kube-system` to `/opt/course/e04/endpoint.txt`.
2. Write the names of all control plane nodes to `/opt/course/e04/cp-nodes.txt`, one per line.
3. On `cp01`, use `etcdctl` with the etcd server certificate files in `/etc/kubernetes/pki/etcd/`
   to write the number of etcd members to `/opt/course/e04/members.txt`, and confirm that every
   member reports healthy.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
