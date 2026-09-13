# q12 — Inspect CSI drivers and use a block volumeMode

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Storage (10%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A database is being migrated to raw block storage.

1. List the CSI drivers registered in the cluster. For each, write its name and whether
   it requires attach (`spec.attachRequired`) to `/opt/q12/drivers.txt`.
2. Write to `/opt/q12/csinodes.txt` each node's name together with the driver-specific
   node ID the CSI driver registered for it.
3. In namespace `raw`, create PVC `block-pvc`: `2Gi`, `ReadWriteOnce`, StorageClass
   `csi-block`, `volumeMode: Block`.
4. Create pod `block-user` (`busybox:1.36`, kept alive) that consumes `block-pvc` as a
   raw device at `/dev/xvdb`. Do **not** mount a filesystem.
5. From inside the pod, prove `/dev/xvdb` is a block device and write the proof to
   `/opt/q12/proof.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
