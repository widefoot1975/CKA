# q04 — Inspect the container runtime with crictl

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | ssh to node `cp01`, then become root |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

`kubectl` on `cp01` is unusable — the API server is not answering. Work at the runtime
level with `crictl`.

1. Write `/etc/crictl.yaml` so `crictl` needs no flags: runtime and image endpoint
   `unix:///run/containerd/containerd.sock`, timeout `10`, debug off.
2. List **all** pod sandboxes on the node, including those that are not ready, and write
   the count to `/opt/q04/sandboxes.txt`.
3. Find the `kube-apiserver` container, including exited ones. Write its container ID and
   state to `/opt/q04/apiserver.txt`.
4. Write the last 20 log lines of that container to `/opt/q04/apiserver.log`.
5. From `crictl inspect`, write the container's log path on the host to
   `/opt/q04/logpath.txt`.
6. List the images on the node and remove the ones no container references.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
