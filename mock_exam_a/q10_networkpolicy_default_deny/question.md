# q10 — Default-deny NetworkPolicy with a selective allow

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The `prod` namespace contains pods labelled `app=db`, `app=api` and `app=web`.

1. Create a NetworkPolicy named `default-deny-ingress` that **blocks all incoming traffic
   to every pod** in the `prod` namespace.
2. Add a second policy named `allow-api-to-db` that permits traffic to pods labelled
   `app=db` **only** from pods labelled `app=api`, and **only** on TCP port 5432.
3. Confirm that `app=api` pods can reach the database and `app=web` pods cannot.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
