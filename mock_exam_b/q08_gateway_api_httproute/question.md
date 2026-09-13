# q08 — Expose a service with the Gateway API

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Servicing & Networking (20%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The cluster has an NGINX Gateway controller installed but the Gateway API types are not
served yet.

1. Install the Gateway API **standard** CRDs and confirm `gateway.networking.k8s.io/v1`
   is served and that a `GatewayClass` named `nginx` exists and is `Accepted`.
2. In namespace `gw`, create deployment/service `shop-svc` (`nginx:1.27`, service port
   `80`) and deployment/service `api-svc` (`nginx:1.27`, service port `8080` to container
   port `80`).
3. Create a `Gateway` named `main-gw` in `gw` using gatewayClassName `nginx`, with one
   listener named `http`, protocol `HTTP`, port `80`, accepting HTTPRoutes **from all
   namespaces**.
4. Create an `HTTPRoute` named `store-route` in `gw` attached to `main-gw`, for hostname
   `store.example.com`, routing `PathPrefix` `/api` to `api-svc:8080` and `PathPrefix`
   `/` to `shop-svc:80`.
5. Confirm the Gateway listener is `Programmed` and that the HTTPRoute reports
   `Accepted=True` and `ResolvedRefs=True`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
