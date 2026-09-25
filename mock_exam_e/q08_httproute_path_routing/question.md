# q08 — Route two paths with one HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Gateway `main-gw` in namespace `infra` has a listener named `http` (HTTP, port 80) that accepts
routes from all namespaces. Namespace `shop` contains Service `catalog` (port 80) and Service
`cart` (port 8080). Both backends answer any path with a short text that contains their own name.

1. Create an HTTPRoute named `shop-route` in namespace `shop`, attached to listener `http` of
   Gateway `main-gw`, for hostname `shop.example.com`.
2. Requests with path prefix `/cart` must go to Service `cart` on port `8080`; all other requests
   (prefix `/`) must go to Service `catalog` on port `80`.
3. Confirm that the Gateway accepted the route, and test both paths with `curl` using the header
   `Host: shop.example.com`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
