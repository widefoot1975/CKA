# q14 — A container is being OOMKilled

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `prod`, Deployment `resizer` keeps restarting. `kubectl get pods` shows a
climbing `RESTARTS` count and the pod flips between `Running` and `CrashLoopBackOff`. The
image is known good; in staging the team measured a peak of about 180Mi.

1. Confirm the container is being killed for memory and not crashing on its own. State
   which field you read and what exit code you expect.
2. Report the container's current memory request and limit and its actual usage, and
   explain in one line why it was killed even though the node has free memory.
3. Set the container's memory request to `128Mi` and limit to `256Mi` on the Deployment,
   and confirm the restarts stop.
4. Write the Pod's QoS class before and after your change to `/opt/course/q14/qos.txt`,
   and state what else the container would need to become `Guaranteed`.
5. The standalone Pod `cache-warm` in `prod` (container `cache`) is healthy with a `64Mi`
   memory limit but needs more headroom before tonight's load test. Raise its memory
   request to `128Mi` and limit to `256Mi` **without deleting, recreating or restarting
   the Pod**, and show that the new values are in effect and its restart count did not
   change.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
