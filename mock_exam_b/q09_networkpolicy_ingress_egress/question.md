# q09 — Restrict both ingress and egress with NetworkPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Servicing & Networking (20%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `payments` holds pod `api` (label `app=api`, listening on `8080`) and pod `db`
(label `app=db`, listening on `5432`). Namespace `frontend` (label
`kubernetes.io/metadata.name=frontend`) holds pod `web` (label `app=web`). Namespace
`scanner` holds pod `probe` (label `app=web`).

Lock `payments` down without changing any pod.

1. Create a policy named `default-deny-all` in `payments` that denies all ingress and all
   egress for every pod in the namespace.
2. Create a policy named `api-allow` in `payments` that allows ingress to `app=api` on
   TCP `8080` **only** from pods labelled `app=web` **in namespace `frontend`** — pod
   `probe` in `scanner` must stay blocked.
3. In the same policy, allow egress from `app=api` to `app=db` in `payments` on TCP `5432`.
4. Allow DNS resolution for `app=api` (UDP and TCP `53` towards `kube-system`).
5. Verify: `web` reaches `api:8080`, `probe` does not, `api` reaches `db:5432`, `api`
   resolves `db.payments.svc.cluster.local`, and `api` cannot reach anything else.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
