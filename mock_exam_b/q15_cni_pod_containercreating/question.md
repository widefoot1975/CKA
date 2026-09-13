# q15 — Pods stuck in ContainerCreating after a CNI failure

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` + ssh to node `worker01`, then become root |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Every pod scheduled to `worker01` is stuck in `ContainerCreating`. Pods on `worker02`
start normally. `worker01` reports `Ready`. Deployment `apps/web` has 4 replicas and only
the ones on `worker02` have an IP.

1. Write the pod event that explains the failure to `/opt/q15/event.txt`.
2. From `worker01`, check the runtime and the CNI state. Write the path of the CNI
   configuration directory and what you found there to `/opt/q15/cni.txt`.
3. Identify the cause and write it to `/opt/q15/cause.txt`.
4. Repair it so every `apps/web` pod reaches `Running` with a pod IP.
5. Clean up any sandbox left behind by the failed attempts.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
