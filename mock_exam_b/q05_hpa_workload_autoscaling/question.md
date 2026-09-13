# q05 — Configure workload autoscaling with an HPA

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `web` contains deployment `frontend` (image `nginx:1.27`, 1 replica) with no
resource fields set. Its owner reports that an HPA they created shows `<unknown>` for CPU.

1. Give the `frontend` container a CPU request of `100m` and a CPU limit of `200m`,
   without editing a manifest file on disk.
2. Create a HorizontalPodAutoscaler named `frontend-hpa` in `web` using
   `autoscaling/v2`, targeting the `frontend` deployment, `minReplicas: 2`,
   `maxReplicas: 8`, scaling on average CPU **utilization** of `60%`.
3. Confirm the HPA reports a real percentage in the `TARGETS` column rather than
   `<unknown>`, and that replicas settled at 2.
4. Write to `/opt/q05/answer.txt` the two prerequisites that must hold before an
   `averageUtilization` metric can be computed at all.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
