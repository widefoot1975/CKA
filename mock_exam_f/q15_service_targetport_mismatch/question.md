# q15 — Endpoints exist but connections are refused

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `shop`, Deployment `payments` runs 2 Pods (image `nginx:1.27`, label
`app=payments`) that are `Running` and `Ready`. Service `payments` (port `80`) selects
them and has endpoints, but every request to the Service fails with `connection refused`.

1. Find out why requests are refused although the Service has endpoints.
2. Fix Service `payments`. Do not change the Deployment.
3. Verify that the EndpointSlice of `payments` now lists the port the Pods actually
   listen on, and that `wget -qO- http://payments` from a temporary `busybox:1.36` Pod in
   namespace `shop` returns the nginx welcome page.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
