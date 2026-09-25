# q11 — Reattach a retained volume to a new Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Deployment `ledger` in namespace `finance` and its PVC were deleted by mistake. The data survived on
PersistentVolume `ledger-pv` (`250Mi`, `ReadWriteOnce`, storageClassName `manual`, reclaim policy
`Retain`), and an administrator has already made it `Available` again. A copy of the Deployment
manifest is at `/opt/course/e11/ledger-deploy.yaml`.

1. Create a PersistentVolumeClaim named `ledger` in namespace `finance` (`ReadWriteOnce`, `250Mi`,
   storageClassName `manual`) that binds to exactly `ledger-pv`.
2. Edit `/opt/course/e11/ledger-deploy.yaml` so that its container mounts PVC `ledger` at
   `/var/lib/ledger`, then apply the file.
3. Confirm that PVC `ledger` is `Bound` to `ledger-pv` and that the `ledger` pod is `Running`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
