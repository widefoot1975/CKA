# q11 — Static PV/PVC provisioning and mounting

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

1. Create a PersistentVolume named `data-pv` with
   - capacity 2Gi, access mode `ReadWriteOnce`, `hostPath` at `/mnt/data`
   - `persistentVolumeReclaimPolicy: Retain`
   - `storageClassName: manual`
2. Create a PersistentVolumeClaim named `data-pvc` requesting 1Gi with the same access
   mode and storage class.
3. Create a pod named `data-pod` using image `nginx` that mounts the claim at
   `/usr/share/nginx/html`.
4. Confirm the PVC is `Bound` and the pod is `Running`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
