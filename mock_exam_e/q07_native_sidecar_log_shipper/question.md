# q07 — Add a native sidecar to an existing Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Deployment `synergy-app` in namespace `synergy` has a single container `app` (`busybox:1.36`)
that appends a line to `/var/log/app.log` every few seconds. The file lives on the `emptyDir`
volume `logs`, which is mounted at `/var/log`.

1. Add a sidecar container named `sidecar` to the Deployment: image `busybox:1.36`, command
   `sh -c 'tail -n+1 -F /var/log/app.log'`, mounting volume `logs` at `/var/log`.
2. Define it as a **native sidecar**: an init container that keeps running for the whole life of
   the pod. Do not change container `app`.
3. Confirm that the new pod shows `2/2` ready and that the logs of container `sidecar` show the
   lines written by `app`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
