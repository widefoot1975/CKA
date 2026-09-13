# q01 — Verify and operate a highly-available control plane

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c3` + ssh to the control plane nodes |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Cluster `k8s-c3` runs a stacked HA control plane. Right now only `cp01` and `cp02` are
joined — `cp03` was rebuilt and must come back.

1. From `cp01`, print the etcd member list with `etcdctl` using the etcd server
   certificates. Write the current member count and how many member failures this
   cluster tolerates **today** to `/opt/q01/quorum.txt`.
2. On `cp01`, produce a join command that `cp03` can use to join **as a control plane
   node**, including a freshly uploaded certificate key. Write it to
   `/opt/q01/join.sh` — do not run it.
3. Drain `cp02` for maintenance, keeping DaemonSet pods in place and allowing pods with
   emptyDir volumes to be evicted. Then make it schedulable again.
4. Write to `/opt/q01/upgrade.txt` which `kubeadm` subcommand upgrades `cp01` and which
   one upgrades `cp02` and `cp03`.
5. Confirm every control plane node is `Ready` and every etcd member answers an
   endpoint health check.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
