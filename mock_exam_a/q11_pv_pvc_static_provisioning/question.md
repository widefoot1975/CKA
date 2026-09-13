# q11 — Static PersistentVolume provisioning

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` + ssh to `worker01` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

This cluster has no dynamic provisioner, so the volume must be prepared by hand.

1. On `worker01`, create the directory `/mnt/data/logs`.
2. Create a PersistentVolume `pv-logs`: 2Gi, `ReadWriteOnce`, `storageClassName: manual`,
   reclaim policy `Retain`, backed by `hostPath` `/mnt/data/logs`.
3. In namespace `ops`, create a PersistentVolumeClaim `pvc-logs` requesting 1Gi
   `ReadWriteOnce` from storage class `manual`, and confirm it binds to `pv-logs`.
4. Create a Pod `logger` in `ops` running `busybox:1.36` with command
   `sh -c 'while true; do date >> /data/out.log; sleep 5; done'`, mounting the claim at
   `/data`. Show the file being written on the node.
5. Create a second claim `pvc-logs-2` in `ops` requesting 3Gi from `manual`, and state in
   one line why it stays `Pending`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
