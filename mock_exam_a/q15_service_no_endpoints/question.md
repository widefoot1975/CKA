# q15 — A Service with no Endpoints

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Requests to the Service `catalog-svc` in the `shop` namespace get no response, even though
all pods are `Running`.

1. Find out why `kubectl get endpoints catalog-svc` is empty.
2. Fix it **without** recreating the pods or the Deployment.
3. Confirm the Service is reachable by name.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
