# q04 — Install and configure an operator

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The manifest bundle for a backup operator is at `/opt/course/q04/operator.yaml`. It
contains a Namespace, a CRD, a ServiceAccount, a ClusterRole, a ClusterRoleBinding and
the controller Deployment.

1. Install the bundle. The operator must end up in namespace `backup-system`.
2. Report the full resource name, API group, version, short name and scope of the
   custom resource the CRD registers.
3. The controller Deployment `backup-operator` comes up but its log repeatedly shows
   `backups.telco.io is forbidden: cannot list resource "backups"`. Find the cause and
   fix it. Do not grant `cluster-admin`.
4. Everyone bound to the built-in `view` ClusterRole must also be able to read `backups`.
   Achieve this **without editing the `view` ClusterRole**, using a new ClusterRole named
   `backup-viewer`.
5. Once the controller reconciles cleanly, create a `Backup` named `nightly` in namespace
   `default` with `spec.schedule: "0 2 * * *"` and `spec.target: pvc/data-web-0`, and
   show that the controller observed it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
