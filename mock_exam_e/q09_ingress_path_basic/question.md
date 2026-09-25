# q09 — Publish a Service with an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `echo` contains Service `echo-svc`, which listens on port `8080` and returns HTTP `200`
for any path. An Ingress controller is installed in the cluster.

1. Find the name of the IngressClass that exists in the cluster.
2. Create an Ingress named `echo` in namespace `echo` that uses this IngressClass and sends
   requests for host `example.org` with path `/echo` (path type `Prefix`) to Service `echo-svc`
   on port `8080`.
3. Using `curl` against the Ingress controller with the header `Host: example.org`, confirm that
   path `/echo` returns HTTP `200`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
