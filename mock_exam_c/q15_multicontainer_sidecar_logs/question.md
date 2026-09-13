# q15 — Read output streams from a multi-container pod

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 11 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `obs` contains pod `tracker` with containers `app`, `shipper` and an init
container `setup`. `kubectl logs tracker` returns an error.

1. Explain why the plain `kubectl logs tracker` fails and list the pod's containers
   without reading the whole manifest.
2. Write the last 20 lines of the `app` container's log to
   `/opt/course/q15/app.log`.
3. The `shipper` container restarted once. Write the log of its **previous** instance to
   `/opt/course/q15/shipper-prev.log` and state the restart reason.
4. Write every line produced by any container in the last 10 minutes containing the
   string `ERROR` to `/opt/course/q15/errors.log`.
5. Create a new pod `tailer` in `obs` that runs `nginx:1.27` writing access logs to
   `/var/log/nginx/access.log` on a shared `emptyDir`, plus a native sidecar named
   `logship` (`busybox:1.36`) that tails that file to its own stdout. Prove that
   `kubectl logs tailer -c logship` shows nginx requests.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
