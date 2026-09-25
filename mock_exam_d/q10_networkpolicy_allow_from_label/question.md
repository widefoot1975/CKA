# q10 — Allow traffic to a backend from one frontend only

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `proj` contains three pods: `backend` (label `app=backend`, serves HTTP on port
`8080`), `frontend` (label `app=frontend`) and `other` (label `app=other`). `frontend` and
`other` run `busybox:1.36`. A NetworkPolicy `deny-all` already blocks all ingress traffic in the
namespace.

1. Create a NetworkPolicy `allow-frontend` in `proj` that applies to pods labelled `app=backend`.
2. It must allow ingress on TCP port `8080` only from pods labelled `app=frontend` in the same
   namespace. Do not modify or delete `deny-all`.
3. Verify that `frontend` can reach `backend` on port 8080 and that the same request from
   `other` times out.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
