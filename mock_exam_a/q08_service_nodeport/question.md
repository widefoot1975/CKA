# q08 — Expose a Deployment through a NodePort Service

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

1. In the `shop` namespace, create a Deployment named `catalog` with image `nginx`,
   3 replicas and container port 80.
2. Expose it as a **NodePort** Service named `catalog-svc` with
   - service port `8080`, target port `80`, and node port fixed at `30080`.
3. Confirm the Service has 3 pod IPs in its Endpoints.
4. Reach the Service by name from inside the cluster, and by node IP on port 30080.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
