# q02 — Read-only pod access for a ServiceAccount

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

A monitoring tool in namespace `apps` will run under its own ServiceAccount. It must be able to
read pods and their logs, and nothing else.

1. Create ServiceAccount `monitor` in namespace `apps`.
2. Create Role `pod-reader` in `apps` that allows the verbs `get`, `list` and `watch` on the
   resources `pods` and `pods/log`.
3. Bind the Role to the ServiceAccount with RoleBinding `monitor-pod-reader` in `apps`.
4. Using `kubectl auth can-i` while impersonating the ServiceAccount, confirm that it can list
   pods and read pod logs in `apps`, but cannot delete pods.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
