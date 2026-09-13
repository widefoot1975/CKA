# q13 — Cluster DNS resolution is failing

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` + ssh to the nodes if needed |
| Target time | 11 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Pods across the cluster cannot resolve any name. `curl http://backend.app.svc.cluster.local`
fails with a lookup error from inside every pod, but `curl http://10.244.2.14` (a pod IP)
works. External names such as `kubernetes.io` also fail.

1. Confirm from inside a pod that this is a DNS failure and not a routing failure.
2. Work out which layer is broken: the pod's resolver config, the `kube-dns` Service, the
   CoreDNS pods, or the CoreDNS configuration.
3. Fix the cluster so that both in-cluster Service names and external names resolve.
4. Write the root cause in one sentence to `/opt/course/q13/cause.txt`.
5. Do not delete the `kube-dns` Service and do not change any pod's `dnsPolicy`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
