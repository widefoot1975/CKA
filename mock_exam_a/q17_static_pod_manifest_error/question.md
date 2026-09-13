# q17 — Control plane down from a static pod manifest error

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Context | ssh to the control plane node `cp01`, then become root |
| Target time | 8 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Every `kubectl` command on `cp01` fails with `connection refused` on port 6443. A colleague
edited a control plane manifest shortly before.

1. Confirm the API server is not listening and that this is not a kubeconfig problem.
2. Without using `kubectl`, list the control plane containers and identify which one is not
   running.
3. Read that container's output and quote the exact error.
4. Back the manifest up, then repair it so the API server comes back. Do not run
   `kubectl apply` and do not restart the kubelet.
5. Confirm the API server answers and all four control plane static pods are running, and
   state in one line the mechanism that restarted the pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
