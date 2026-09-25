# q11 — Protect a dynamically provisioned volume

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `db`, PVC `pg-data` is `Bound` to a PersistentVolume that was dynamically
provisioned by a StorageClass with reclaim policy `Delete`. The data on that volume must
survive even if the PVC is deleted by mistake.

1. Write the name of the PersistentVolume bound to PVC `pg-data` to
   `/opt/course/f11/pv.txt`.
2. Change the reclaim policy of that PersistentVolume to `Retain`, without recreating the
   PV, the PVC or the StorageClass.
3. Verify that `kubectl get pv` shows `Retain` for that volume and that `pg-data` is still
   `Bound`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
