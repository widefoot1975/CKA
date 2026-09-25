# q06 — Inject a ConfigMap as an env var and a file

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `cfg` exists. An application needs one setting as an environment variable and all
settings as files.

1. Create ConfigMap `app-settings` in `cfg` with the keys `MODE=prod` and `COLOR=blue`.
2. Create pod `settings-demo` in `cfg` (image `busybox:1.36`, command `sleep 3600`) that
   - receives the value of key `MODE` as environment variable `APP_MODE`, and
   - mounts the whole ConfigMap as a volume at `/etc/settings`.
3. Verify inside the pod that `APP_MODE` is `prod` and that the file `/etc/settings/COLOR`
   contains `blue`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
