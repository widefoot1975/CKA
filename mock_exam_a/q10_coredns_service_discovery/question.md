# q10 — Service discovery with CoreDNS

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Servicing & Networking (20%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Two namespaces expose a Service of the same name and clients keep reaching the wrong one.

1. Create namespaces `alpha` and `beta`. In each, create a Deployment `web` running
   `nginx:1.27` and a ClusterIP Service `web` on port 80.
2. Report which Deployment provides cluster DNS in `kube-system`, which Service fronts it,
   and which ConfigMap holds its Corefile.
3. From a debug pod in `alpha`, resolve `web`, `web.beta`, `web.beta.svc.cluster.local` and
   `web.beta.cluster.local`. Record which one fails.
4. Print that pod's `/etc/resolv.conf` and explain why a bare `web` resolves to `alpha`.
5. Create a Pod `no-dns` in `alpha` that does not use cluster DNS at all, and show that
   `web` no longer resolves inside it.
6. Write the FQDN a client uses to reach one specific pod behind a headless Service.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
