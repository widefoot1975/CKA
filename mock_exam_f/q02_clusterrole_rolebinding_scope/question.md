# q02 — Reuse a ClusterRole inside one namespace

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

User `dev-anna` needs read-only access to Deployments, but only in namespace `team-a`.
Namespaces `team-a` and `team-b` already exist. The permissions must be defined once, at
cluster level, so that they can be reused for other namespaces later.

1. Create ClusterRole `deployment-viewer` that allows the verbs `get`, `list` and `watch`
   on `deployments` in API group `apps`.
2. Grant `deployment-viewer` to user `dev-anna` **only in namespace `team-a`**, using a
   binding named `anna-deploy-view`.
3. Verify with `kubectl auth can-i ... --as=dev-anna` that `dev-anna` can list Deployments
   in `team-a`, but not in `team-b` and not across all namespaces.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
