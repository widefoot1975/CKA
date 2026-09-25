# q11 — Create a default StorageClass

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

The local-path provisioner (`rancher.io/local-path`) is installed, and the cluster already has
a default StorageClass.

1. Create StorageClass `local-fast` with provisioner `rancher.io/local-path`, reclaimPolicy
   `Delete` and volumeBindingMode `WaitForFirstConsumer`.
2. Make `local-fast` the default StorageClass of the cluster.
3. Make the StorageClass that was the default before (check `kubectl get sc`) no longer the
   default, and confirm that exactly one StorageClass is marked `(default)`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
