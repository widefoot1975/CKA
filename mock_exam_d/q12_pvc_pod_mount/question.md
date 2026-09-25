# q12 — Claim storage and mount it in a Pod

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `data` exists. StorageClass `local-path` (provisioner `rancher.io/local-path`,
volumeBindingMode `WaitForFirstConsumer`) is available.

1. Create a PersistentVolumeClaim `app-data` in `data` that requests `1Gi` with access mode
   `ReadWriteOnce` from StorageClass `local-path`. Confirm that it is `Pending` while no pod
   uses it.
2. Create pod `writer` in `data` (image `busybox:1.36`) that mounts the claim at `/data` and
   runs `sh -c 'date > /data/out.txt; sleep 3600'`.
3. Confirm that the claim is now `Bound` and that `/data/out.txt` in the pod contains the date.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
