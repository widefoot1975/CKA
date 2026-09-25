# q15 — A Service with no endpoints

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `store`, requests to Service `catalog` (port 80) fail. Deployment `catalog`
(2 replicas, image `nginx:1.27`) is running and its pods are `Ready`.

1. Show that the Service has no endpoints by looking at its EndpointSlice.
2. Find the reason by comparing the Service's selector with the labels of the `catalog` pods.
3. Fix the Service so that it selects the `catalog` pods. Do not change the Deployment or the
   pods.
4. Confirm that the EndpointSlice now lists 2 pod addresses.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
