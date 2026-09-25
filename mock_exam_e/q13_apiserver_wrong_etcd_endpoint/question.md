# q13 — API server down after a machine migration

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c2` → `ssh cp01`, then `sudo -i` |
| Target time | 9 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The single-node cluster `k8s-c2` was moved to a new machine, `cp01`. Since the move, every
`kubectl` command fails with `The connection to the server ... was refused`. etcd and the kubelet
on `cp01` are running normally.

1. On `cp01`, find out why kube-apiserver does not stay up. Use the container runtime and the
   static pod manifest; `kubectl` cannot help until the API server works.
2. Fix the kube-apiserver static pod manifest. Keep a backup copy of the original file outside
   `/etc/kubernetes/manifests`.
3. Write the wrong setting value you found to `/opt/course/e13/cause.txt`.
4. Confirm that `kubectl get nodes` works again and shows `cp01` as `Ready`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
