# q04 — Identify the CRI, CNI and CSI in use

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker01` for the node steps |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Document which container runtime, network plugin and storage drivers cluster `k8s-c1`
uses. Write all answer files on `k8s-c1`; read the node-local files on `worker01`.

1. Write each node's name and the container runtime (with version) that the node reports
   to `/opt/course/f04/runtime.txt`, one node per line.
2. On `worker01`, find the `containerRuntimeEndpoint` set in `/var/lib/kubelet/config.yaml`
   and write its value to `/opt/course/f04/endpoint.txt`.
3. On `worker01`, the container runtime uses the first file in lexical order in
   `/etc/cni/net.d/`. Write that file name and the `type` of the first plugin in it to
   `/opt/course/f04/cni.txt`, in the form `<file> <type>`.
4. Write the names of all CSI drivers registered in the cluster to
   `/opt/course/f04/csi.txt`, one per line.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
