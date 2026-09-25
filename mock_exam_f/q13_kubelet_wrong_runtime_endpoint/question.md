# q13 — Node NotReady after a kubelet config change

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 9 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Node `worker02` became `NotReady` shortly after someone edited the kubelet configuration
file `/var/lib/kubelet/config.yaml` on that node. containerd on `worker02` is running
normally.

1. On `worker02`, find out why the kubelet does not stay running. Write the wrong
   configuration value you found to `/opt/course/f13/cause.txt` on `worker02`.
2. Fix the configuration and restart the kubelet.
3. Confirm from `k8s-c1` that `worker02` is `Ready`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
