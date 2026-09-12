# q02 — Back up and restore etcd from a snapshot

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 8 |
| Context | ssh to the control plane node, then become root |
| Target time | 12 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The control plane node runs a stacked etcd. Perform the following.

1. Save an etcd snapshot to `/opt/etcd-backup.db`.
2. After taking the snapshot, create an arbitrary ConfigMap so you can tell later whether
   the restore took effect.
3. Restore that snapshot into `/var/lib/etcd-restore` and make the etcd static pod use
   that directory.
4. Confirm the cluster is healthy again and that **the ConfigMap from step 2 is gone**.

Do not rely on memorised certificate paths — find them in the manifest.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
