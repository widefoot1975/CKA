# q14 — Gateway accepts traffic but nothing reaches the backend

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `gw`, Gateway `main-gw` has an address and its `http` listener is
`Programmed`. Services `shop-svc` (port `80`) and `api-svc` (port `8080`) are Running with
healthy endpoints. But `curl -H 'Host: store.example.com' http://<gw-address>/` returns
`404` and `/api` returns `503`.

Fix the routing. Do **not** change the Gateway's listener configuration and do not change
either Service.

1. Write the `Accepted` and `ResolvedRefs` conditions of HTTPRoute `store-route`, with
   their reasons, to `/opt/q14/conditions.txt`.
2. Decide for each of the two failing paths whether the fault is route attachment,
   hostname matching, or backend resolution.
3. Repair `store-route` so `/` reaches `shop-svc` and `/api` reaches `api-svc`.
4. Verify both paths return `200` with the correct backend.
5. Write the root cause of each of the two symptoms in one line each to
   `/opt/q14/cause.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
