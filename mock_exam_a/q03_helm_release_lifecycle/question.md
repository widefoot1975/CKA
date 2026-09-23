# q03 — Manage a cluster component with Helm

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Use Helm to install cert-manager as a cluster component in namespace `cert-manager`.
Write every answer file under `/root/helm/`.

1. Add the chart repository `jetstack` at `https://charts.jetstack.io`, refresh the index,
   and write the latest version of chart `jetstack/cert-manager` to
   `/root/helm/version.txt`. Pass exactly that version with `--version` in every later step.
2. Save the chart's default values to `/root/helm/values.yaml` **without installing
   anything**, and write the names of the values that control CRD installation to
   `/root/helm/crd-values.txt`.
3. Install release `cert-manager` into `cert-manager`, creating the namespace, with the
   CRDs installed by the chart and the controller running `2` replicas.
4. Upgrade the release so the controller runs `3` replicas **without losing any value set
   in step 3**. Show the release history, roll back to revision 1, and confirm the
   controller is back to 2 replicas and the CRDs still exist.
5. Using only `kubectl`, write the documentation of the field `spec.dnsNames` of the
   `Certificate` resource to `/root/helm/dnsnames.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
