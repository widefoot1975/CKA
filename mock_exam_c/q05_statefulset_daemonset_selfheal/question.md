# q05 — Self-healing with StatefulSet and DaemonSet

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

In namespace `infra`:

1. Create a DaemonSet `node-agent` running `busybox:1.36` with the command
   `sh -c 'while true; do sleep 30; done'`. It must run on **every** node including
   control plane nodes.
2. Create a StatefulSet `cache` with 3 replicas of `redis:7.2`, governed by an existing
   headless Service named `cache`, container port 6379.
3. Delete the pod `cache-1` and record what the controller recreates — the pod name and
   whether the ordinal is preserved.
4. Delete the `node-agent` pod on one worker node and record how quickly it returns.
5. In one line each, state which object the DaemonSet controller reconciles against and
   what the StatefulSet guarantees that a Deployment does not.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
