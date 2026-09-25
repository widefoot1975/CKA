# q03 — Explore installed CRDs with kubectl

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

cert-manager is installed in the cluster. Using only `kubectl`, collect information about the
custom resources it added.

1. Write the names of all CustomResourceDefinitions whose API group ends with `cert-manager.io`
   to `/opt/course/d03/crds.txt`, one name per line (for example `certificates.cert-manager.io`).
2. Write the `kubectl explain` documentation of the field `spec.renewBefore` of the
   `Certificate` resource to `/opt/course/d03/renewbefore.txt`.
3. Write the short names of the `certificates` resource to `/opt/course/d03/shortnames.txt`,
   one per line.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
