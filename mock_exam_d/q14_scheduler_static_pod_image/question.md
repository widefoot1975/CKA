# q14 — Pods stay Pending because the scheduler is broken

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Newly created pods stay `Pending` and show no events. `kubectl -n kube-system get pods` shows
`kube-scheduler-cp01` in `ImagePullBackOff`.

1. On `cp01`, find what is wrong in the kube-scheduler static pod manifest.
2. Before changing it, copy the manifest to `/opt/course/d14/kube-scheduler.yaml.bak` on `cp01`.
3. Fix the manifest so that kube-scheduler uses the same image tag as the kube-apiserver
   manifest.
4. Confirm that `kube-scheduler-cp01` is `Running` and that a new pod `sched-test`
   (image `nginx:1.27`, namespace `default`) gets scheduled to a node.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
