# q13 — Recover a NotReady node

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` + ssh to `worker01`, then become root |
| Target time | 9 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Node `worker01` reports `NotReady` and its pods are stuck in `Terminating` or `Pending`.

1. From the control plane, identify which node condition is failing and what the kubelet
   last reported as the reason and message.
2. On `worker01`, report whether the kubelet unit is running and read its last 50 log lines.
3. Report the state of the container runtime on that node.
4. Identify the root cause and repair it so the node returns to `Ready`.
5. Confirm the node is `Ready` and that a new pod can be scheduled onto it.
6. Write down the order in which you narrowed the cause, one line per step.
7. Name one situation in which the kubelet is healthy and running but the node still
   reports `NotReady`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
