# q17 — Service traffic broken by kube-proxy

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` + ssh to `worker01`, then become root |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `app`, Service `web` (ClusterIP, port 80) has 3 healthy endpoints. From a
pod, `curl http://<pod-ip>:80` works for every backend pod, but
`curl http://web.app.svc.cluster.local` and `curl http://<cluster-ip>:80` both hang. A
NodePort Service `web-np` is also unreachable from outside. Pods on `worker01` are the
only ones affected.

1. Rule out DNS and endpoints as the cause — show the two commands that do it.
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
