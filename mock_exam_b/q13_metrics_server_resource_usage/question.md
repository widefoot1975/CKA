# q13 — Restore metrics-server and analyse resource usage

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 11 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

`kubectl top nodes` fails on this cluster. An HPA in namespace `prod` is stuck showing
`<unknown>` as a consequence.

1. Write the exact error `kubectl top nodes` prints to `/opt/q13/error.txt`.
2. Determine whether the fault is the APIService registration, the metrics-server pod, or
   the connection from metrics-server to the kubelets. Write which one, and the command
   that decided it, to `/opt/q13/cause.txt`.
3. Fix it so that `kubectl top nodes` and `kubectl top pods -A` both return numbers.
   Do not delete the metrics-server Deployment.
4. Write the name of the pod using the most memory in namespace `prod` to
   `/opt/q13/top-mem.txt`.
5. For deployment `api` in `prod`, write the per-container CPU usage to
   `/opt/q13/api-containers.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
