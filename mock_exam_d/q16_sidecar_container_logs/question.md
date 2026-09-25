# q16 — Read logs from an app and its sidecar

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

Namespace `logs` contains pod `order-api` with an app container `api` and a native sidecar
container `log-agent` (declared under `initContainers` with `restartPolicy: Always`).

1. Write the last 10 lines of the `log-agent` container's log to `/opt/course/d16/agent.log`.
2. Container `api` has restarted once. Write the log of its previous instance to
   `/opt/course/d16/api-previous.log`.
3. Write every log line from the last 30 minutes, from all containers of the pod, that contains
   `ERROR` to `/opt/course/d16/errors.log`. Each line must be prefixed with the name of the
   container it came from.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
