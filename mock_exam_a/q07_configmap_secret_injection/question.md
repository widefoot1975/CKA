# q07 — Inject a ConfigMap and Secret as env vars and a volume

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In the `app` namespace, create the following.

1. A ConfigMap named `app-config` with `APP_MODE=production` and `LOG_LEVEL=warn`.
2. A Secret named `db-credentials` with `DB_USER=admin` and `DB_PASSWORD=s3cr3t`.
3. A pod named `configured-app` using image `nginx` that
   - injects **all keys** of the ConfigMap as environment variables,
   - injects **only** the Secret key `DB_PASSWORD` as the environment variable
     `DATABASE_PASSWORD`, and
   - mounts the **entire Secret** at `/etc/db` as a read-only volume.
4. Verify the environment variables and the mounted files from inside the pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
