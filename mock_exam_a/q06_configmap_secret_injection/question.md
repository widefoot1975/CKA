# q06 — Configure an application with a ConfigMap and Secret

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

An application in namespace `web` takes its settings from the cluster, not from its image.

1. Create a ConfigMap `app-config` with `APP_MODE=production` and `LOG_LEVEL=warn`.
2. Create a ConfigMap `app-files` with key `app.properties` = `timeout=30\nretries=3`.
3. Create a generic Secret `db-cred` with `username=appuser` and `password=S3cr3t!`.
4. Create a Pod `web-app` running `nginx:1.27` that
   - receives every key of `app-config` as an environment variable in one block
   - receives only the `password` key of `db-cred` as the variable `DB_PASSWORD`
   - mounts `db-cred` read-only at `/etc/db`
   - mounts `app.properties` at `/etc/app/app.properties` without hiding `/etc/app`
5. Show the variables and the mounted files from inside the container, and state in one
   line why the `/etc/app/app.properties` mount will not see a later edit of `app-files`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
