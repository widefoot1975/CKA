# q06 — Constrain a namespace with ResourceQuota and LimitRange

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

Namespace `team-a` must be capped, and its users must not have to write resource fields
by hand.

1. Create namespace `team-a` and a ResourceQuota named `team-a-quota` with
   `requests.cpu: "1"`, `requests.memory: 1Gi`, `limits.cpu: "2"`,
   `limits.memory: 2Gi`, `pods: "10"`, `configmaps: "5"`.
2. Try to create a pod named `probe` with image `nginx:1.27` and **no** resource fields.
   Write the exact rejection message to `/opt/q06/rejected.txt`.
3. Create a LimitRange named `team-a-defaults` for `Container` with
   `defaultRequest` cpu `100m` / memory `128Mi`, `default` cpu `200m` /
   memory `256Mi`, and `max` cpu `500m`.
4. Create `probe` again, still with no resource fields, and show the values it was given.
5. Show the quota's used-versus-hard figures and confirm `requests.cpu` used is `100m`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
