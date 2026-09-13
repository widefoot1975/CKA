# q16 — Pods evicted under node disk pressure

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` + ssh to `worker02`, then become root |
| Target time | 11 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Pods on `worker02` are disappearing. Several show status `Evicted`, and new pods stay
`Pending` with no node chosen. Other nodes are unaffected.

1. Show the node condition that explains this and the message the kubelet attached to it.
2. Report the kubelet eviction thresholds in effect on `worker02` and which filesystem
   signal crossed its threshold.
3. Find what is consuming the disk, distinguishing container images from container logs
   from other data.
4. Reclaim space so the condition clears. Remove unused images through the container
   runtime, not by deleting files under `/var/lib/containerd` by hand.
5. Confirm the node accepts pods again, and clean up the `Evicted` pod objects.
6. Note the difference between an evicted pod and an OOMKilled container in one line.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
