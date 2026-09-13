# q09 — Route traffic with an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Servicing & Networking (20%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Two applications in namespace `web` must share one hostname.

1. Create Deployments `site` and `api` in `web`, 2 replicas each, image
   `registry.k8s.io/e2e-test-images/echoserver:2.5`, container port 8080.
2. Expose each with a ClusterIP Service on port 80 targeting 8080, named `site-svc` and
   `api-svc`.
3. Find the IngressClass available in this cluster and note its name.
4. Create an Ingress `shop-ingress` in `web` for host `shop.example.com` on that class:
   `/` and everything below it → `site-svc:80`, `/api` and everything below → `api-svc:80`.
5. Add a rule routing exactly `/health` to `api-svc:80`; `/health/extra` must not match.
6. Verify all three paths with `curl` and a `Host` header.
7. State in one line what happens if `pathType` is left out of a rule.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
