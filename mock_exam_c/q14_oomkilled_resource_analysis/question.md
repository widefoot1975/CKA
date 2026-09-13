# q14 — A container is being OOMKilled

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 11 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `prod`, Deployment `resizer` keeps restarting. `kubectl get pods` shows a
climbing `RESTARTS` count and the pod flips between `Running` and `CrashLoopBackOff`. The
image is known good and ran fine in staging.

1. Confirm the container is being killed for memory and not crashing on its own. State
   which field you read and what exit code you expect.
2. Report the container's current memory request and limit, and its actual usage.
3. Explain in one line why the pod was killed even though the node has free memory.
4. Raise the limit to the smallest round value that stops the kills, keeping the request
   at a value that still lets the pod schedule, and confirm the restarts stop.
5. Write the container's QoS class before and after your change to
   `/opt/course/q14/qos.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
