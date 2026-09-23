# q01 — Verify and operate a highly-available control plane

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c3` → `ssh cp01`, then `sudo -i` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Cluster `k8s-c3` runs a stacked HA control plane on `cp01`, `cp02` and `cp03`. `cp03` died
and was rebuilt from scratch without running `kubeadm reset`, so its old etcd member is still
registered. The rebuilt `cp03` must come back.

1. From `cp01`, print the etcd member list and the health of every member with `etcdctl`,
   using the etcd server certificates. Write the number of registered members, how many are
   healthy, and how many **additional** member failures the cluster tolerates today to
   `/opt/q01/quorum.txt`.
2. Remove the stale `cp03` member from etcd, and the old `cp03` Node object if it still
   exists, so the rebuilt machine can join again.
3. On `cp01`, produce a join command that `cp03` can use to join **as a control plane
   node**, including a freshly uploaded certificate key. Write it to `/opt/q01/join.sh` —
   do not run it.
4. Write to `/opt/q01/upgrade.txt` which `kubeadm` subcommand upgrades `cp01` and which one
   upgrades `cp02` and `cp03`.
5. Confirm `cp01` and `cp02` are `Ready` and every remaining etcd member answers an
   endpoint health check.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
