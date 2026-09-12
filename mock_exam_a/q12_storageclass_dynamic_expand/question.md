# q12 — Dynamic provisioning and PVC expansion

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

1. Create a StorageClass named `fast-local` that
   - uses provisioner `rancher.io/local-path` (use the one installed in the cluster; if
     none exists, use `kubernetes.io/no-provisioner`)
   - has `volumeBindingMode: WaitForFirstConsumer`
   - **allows volume expansion**
   - is the cluster's **default** StorageClass
2. Create a PVC named `app-pvc` requesting 1Gi from this StorageClass.
3. Create a pod named `app-pod` using image `nginx` that consumes the PVC, and observe
   when the PVC becomes `Bound`.
4. Expand the PVC to 3Gi.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
