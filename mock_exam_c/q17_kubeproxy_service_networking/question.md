# q17 — Service traffic broken by kube-proxy

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker01`, then `sudo -i` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

`worker01` was rebooted this morning after kernel maintenance. Since then, in namespace
`app`, Service `web` (ClusterIP, port 80) still has 3 healthy endpoints, and from a pod
**on `worker01`** `curl http://<pod-ip>:80` works for every backend pod, but
`curl http://web.app.svc.cluster.local` and `curl http://<cluster-ip>:80` both hang.
NodePort Service `web-np` is unreachable through `worker01`'s IP. Pods on other nodes are
not affected.

1. Show that neither CoreDNS nor the Service's endpoints are the cause — one command each.
2. Identify the component responsible for ClusterIP translation and check its state on
   `worker01`.
3. Inspect the node's NAT rules to show the Service chains are missing.
4. Find and fix the root cause. Do not recreate the Service.
5. Verify ClusterIP and NodePort both work again.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
