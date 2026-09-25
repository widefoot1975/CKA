# q10 — Add a static DNS record with CoreDNS

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Pods in the cluster must be able to resolve the name `db.internal` to `10.0.0.50`. The
record must be served by the cluster DNS (CoreDNS); do not change the Pods' own
`/etc/hosts`.

1. Back up ConfigMap `coredns` in namespace `kube-system` to
   `/opt/course/f10/coredns-backup.yaml`.
2. Add a `hosts` entry to the Corefile in that ConfigMap so that `db.internal` resolves to
   `10.0.0.50`, while every other name keeps resolving as before.
3. Make sure CoreDNS uses the new configuration. Then verify from a temporary
   `busybox:1.36` Pod that `db.internal` resolves to `10.0.0.50` and that
   `kubernetes.default.svc.cluster.local` still resolves.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
