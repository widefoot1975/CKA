# q12 — Combine a Secret, a ConfigMap and pod labels in one volume

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `proj` contains Secret `db-cred` with key `password` and ConfigMap `app-cfg`
with key `app.conf`.

1. Create Pod `projected-demo` in namespace `proj` with label `app=demo`, image
   `busybox:1.36` and command `sleep 3600`.
2. Mount a single `projected` volume read-only at `/etc/app` in that Pod. It must provide:
   - key `password` of Secret `db-cred` as `/etc/app/password`
   - key `app.conf` of ConfigMap `app-cfg` as `/etc/app/app.conf`
   - the Pod's labels (Downward API field `metadata.labels`) as `/etc/app/labels`
3. Verify with `ls` and `cat` inside the Pod that all three files exist and contain the
   expected data.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
