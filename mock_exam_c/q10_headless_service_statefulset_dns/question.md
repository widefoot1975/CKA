# q10 — Headless Service and StatefulSet pod DNS

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Servicing & Networking (20%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `data`, build a stable per-pod addressing scheme.

1. Create a headless Service `db` selecting `app=db`, port 5432 named `pg`.
2. Create a StatefulSet `db` with 3 replicas of `nginx:1.27` (stand-in for the real
   database), labelled `app=db`, container port 5432, governed by the `db` Service.
3. From a temporary pod in the same namespace, resolve:
   - the Service name `db`
   - the individual pod `db-0`
   Record what each returns and how they differ.
4. Write the fully qualified DNS name of `db-2` into `/opt/course/q10/fqdn.txt`.
5. Create a second, normal ClusterIP Service `db-rw` on the same selector and port, and
   show how its DNS answer differs from the headless one.
6. Explain why `db-0` is resolvable but a Deployment's pods are not resolvable by name.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
