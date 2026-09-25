# q08 — Expose a Service through the Gateway API

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

GatewayClass `nginx` is installed and `Accepted`. Namespace `web` contains Deployment
`frontend` and Service `frontend` (port 80).

1. Create a Gateway `web-gw` in `web` with gatewayClassName `nginx` and a single listener named
   `http`: protocol `HTTP`, port `80`.
2. Create an HTTPRoute `frontend-route` in `web`, attached to the `http` listener of `web-gw`,
   for hostname `shop.example.com`, that sends path prefix `/` to Service `frontend` on port 80.
3. Verify that the Gateway is `Programmed`, that the route reports `Accepted=True` and
   `ResolvedRefs=True`, and that an HTTP request to the Gateway address with host
   `shop.example.com` returns the frontend page.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
