# q08 — Weighted traffic splitting with HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Servicing & Networking (20%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The Gateway API CRDs are installed and a Gateway named `web-gw` exists in namespace
`gateway-system` with an HTTP listener named `http` on port 80 that allows routes from
all namespaces.

In namespace `shop`:

1. Confirm the Gateway API is available and report the API group and version of the
   `HTTPRoute` resource.
2. Deployments `shop-v1` and `shop-v2` already exist. Create ClusterIP Services
   `shop-v1` and `shop-v2`, port 80 targeting container port 80.
3. Create an HTTPRoute `shop-route` attached to `web-gw`, for hostname
   `shop.example.com`, matching path prefix `/`, that sends 90% of requests to `shop-v1`
   and 10% to `shop-v2`.
4. Add a second rule on path prefix `/canary` that sends **all** traffic to `shop-v2`,
   regardless of the weighting above.
5. Confirm the route was accepted by the Gateway and that the parent reference resolved.
6. State in one line what the numbers in `weight` actually mean.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
