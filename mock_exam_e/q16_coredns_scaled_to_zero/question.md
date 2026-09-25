# q16 — Cluster DNS stopped working

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In cluster `k8s-c1`, pods can no longer resolve any DNS name, not even `kubernetes.default`.
Connections to pod IP addresses still work.

1. Find out why cluster DNS does not answer. Start from Service `kube-dns` in namespace
   `kube-system` and its EndpointSlice.
2. Fix the problem so that cluster DNS runs with `2` replicas again.
3. Write the kind and name of the object you had to fix, in the form `<kind>/<name>` (for example
   `daemonset/foo`), to `/opt/course/e16/cause.txt`.
4. From a temporary `busybox:1.36` pod, confirm that
   `nslookup kubernetes.default.svc.cluster.local` succeeds.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
