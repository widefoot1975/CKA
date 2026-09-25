# q14 — Node NotReady because the container runtime is down

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Node `worker02` of cluster `k8s-c1` is `NotReady`. The kubelet service on `worker02` is running.

1. On `worker02`, use the kubelet journal to find out why the node is `NotReady`.
2. Fix the cause so that the fix also survives a reboot of `worker02`.
3. Write the name of the systemd service that caused the problem to `/opt/course/e14/cause.txt`
   on `worker02`.
4. Confirm that `worker02` becomes `Ready`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
