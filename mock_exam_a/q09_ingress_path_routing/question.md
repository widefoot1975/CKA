# q09 — Path-based routing with an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

An Ingress controller is already installed in the cluster.

1. In the `web` namespace, create Deployments `api` and `ui`, both with image `nginx` and
   2 replicas, and expose each as a ClusterIP Service named `api-svc` and `ui-svc` on
   port 80.
2. Create an Ingress named `app-ingress` for host `shop.example.com` that routes
   - requests to `/api` → `api-svc:80`
   - requests to `/` → `ui-svc:80`
3. Use `pathType: Prefix`.
4. Confirm the Ingress has an address and that the rules are as intended.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
