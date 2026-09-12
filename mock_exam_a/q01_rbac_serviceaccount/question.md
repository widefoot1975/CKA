# q01 — Least-privilege Role for a ServiceAccount

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 5 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In the `monitoring` namespace, configure the following.

1. Create a ServiceAccount named `metrics-reader`.
2. Create a Role named `pod-reader` that grants **only** `get`, `list` and `watch` on the
   `pods` and `pods/log` resources.
3. Create a RoleBinding named `read-pods` that binds the Role to the ServiceAccount.
4. Verify the result with `kubectl auth can-i`: `metrics-reader` must be able to read pods
   but **must not** be able to delete them.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
