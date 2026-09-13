# q01 — Namespaced RBAC for a deployment operator

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

A deployment automation tool needs limited access to the `staging` namespace.

1. Create a ServiceAccount named `deploy-bot` in the `staging` namespace.
2. Create a Role named `deployment-operator` granting
   - `get`, `list`, `watch`, `update` and `patch` on `deployments`
   - `update` and `patch` on `deployments/scale`
   - `get` and `list` on `pods`
3. Bind the Role to the ServiceAccount with a RoleBinding named `deploy-bot-binding`.
4. Verify that `deploy-bot` can scale a deployment in `staging` but **cannot** delete
   deployments, and **cannot** read deployments in the `default` namespace.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
