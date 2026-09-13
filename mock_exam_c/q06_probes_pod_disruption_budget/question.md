# q06 — Probes and a PodDisruptionBudget

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `shop` contains Deployment `api` with 3 replicas of `nginx:1.27`, labelled
`app=api`, serving on port 80.

1. Add a startup probe: HTTP GET `/` on port 80, allowed up to 60 seconds to come up,
   probing every 5 seconds.
2. Add a readiness probe: HTTP GET `/healthz` on port 80, every 5 seconds,
   `failureThreshold: 2`.
3. Add a liveness probe: TCP socket on port 80, `periodSeconds: 10`,
   `failureThreshold: 3`.
4. Create a PodDisruptionBudget `api-pdb` for `app=api` that keeps at least 2 pods
   available.
5. `/healthz` does not exist on the nginx image, so readiness will fail. Show the effect
   on the Service `api` endpoints, then make readiness pass by pointing the probe at a
   path that exists.
6. Attempt `kubectl drain` on the node holding two `api` pods and report what the PDB does.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
