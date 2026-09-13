# q16 — Read and evaluate container output streams

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` + ssh to the node running the pod |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Deployment `multi` in `logs` runs 3 replicas of containers `app` and `shipper`.

1. Print the output of `app` alone, then the output of both containers of one pod at once
   with each line tagged by container.
2. Print the last 20 lines of `app` with timestamps, then only the last 5 minutes of it.
3. Follow `app` live, and print the output of the previous instance of `app` after a restart.
4. Print the output for the whole Deployment, then for all three pods, and state in one line
   why those two are not the same.
5. On the node, locate the on-disk log file of one of these containers and read the same
   output with `crictl` instead of `kubectl`.
6. State in one line how `shipper` must be declared so that it starts before `app` and keeps
   running for the life of the pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
