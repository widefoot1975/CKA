# q14 — Diagnose a CrashLoopBackOff pod

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Pod `broken-app` in namespace `dev` is in `CrashLoopBackOff`.

1. Report its restart count, the last exit code and the termination reason of the failing
   container.
2. Read the output of the instance that crashed, not of the one currently starting.
3. From the exit code, name the most likely cause before changing anything.
4. Repair the pod so it stays `Running`.
5. For exit codes 0, 1, 127 and 137 write the usual cause, one line each.
6. State in one line how you distinguish `CrashLoopBackOff` from `ImagePullBackOff` without
   reading any logs.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
