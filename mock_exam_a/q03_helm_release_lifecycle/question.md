# q03 — Manage a cluster component with Helm

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Use Helm to install and manage a component in the `web` namespace.

1. Add the chart repository `bitnami` at `https://charts.bitnami.com/bitnami` and refresh
   the index.
2. Save the chart's default values to `/tmp/nginx-values.yaml` **without installing
   anything**.
3. Install `bitnami/nginx` as release `frontend` into `web`, creating the namespace, with
   `replicaCount` set to `2`.
4. Upgrade the release to `replicaCount=4` **without losing the values already set**.
5. Show the release history, roll back to revision 1, and confirm the replica count is 2
   again.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
