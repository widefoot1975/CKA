# q14 — Gateway accepts traffic but nothing reaches the backend

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `gw`, Gateway `main-gw` has an address and its `http` listener is
`Programmed`. Services `shop-svc` (port `80`) and `api-svc` (port `8080`) are Running with
healthy endpoints. Two HTTPRoutes are meant to serve host `store.example.com` through that
listener: `store-route` sends `/` to `shop-svc`, and `api-route` sends `/api` to `api-svc`.
But `curl -H 'Host: store.example.com' http://<gw-address>/` returns `404` and `/api`
returns `500`.

Fix the routing. Do **not** change the Gateway's listener configuration and do not change
either Service.

1. Write the `Accepted` and `ResolvedRefs` conditions of both HTTPRoutes, with their
   reasons, to `/opt/q14/conditions.txt`.
2. Decide for each of the two failing paths whether the fault is route attachment,
   hostname matching, or backend resolution.
3. Repair the routes so `/` reaches `shop-svc` and `/api` reaches `api-svc`.
4. Verify both paths return `200` from the correct backend.
5. Write the root cause of each symptom in one line each to `/opt/q14/cause.txt`, plus the
   status code you would expect instead if `api-svc` were valid but had no ready endpoints.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
