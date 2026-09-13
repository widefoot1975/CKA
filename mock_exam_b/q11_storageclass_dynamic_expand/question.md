# q11 — Dynamic provisioning and volume expansion

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Storage (10%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The cluster has one StorageClass, which is the default and does not allow expansion.

1. Create a StorageClass named `fast-expand` reusing the **same provisioner** as the
   existing default class, with `allowVolumeExpansion: true`,
   `volumeBindingMode: WaitForFirstConsumer` and `reclaimPolicy: Delete`.
2. Make `fast-expand` the cluster default and make sure the previous default class is no
   longer marked as default.
3. In namespace `store`, create PVC `data-pvc` requesting `1Gi`, access mode
   `ReadWriteOnce`, from `fast-expand`. Create pod `writer` (`nginx:1.27`) mounting it at
   `/data`.
4. Expand `data-pvc` to `3Gi` and confirm both the PVC `status.capacity` and the
   filesystem inside `writer` report the new size.
5. Write to `/opt/q11/pending.txt` the PVC condition you would see if the driver could
   only expand offline, and what you would do about it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
