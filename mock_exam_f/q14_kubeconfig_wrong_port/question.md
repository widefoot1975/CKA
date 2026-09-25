# q14 — kubectl cannot reach the API server

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

On `k8s-c1`, every `kubectl` command fails, for example:

```
$ kubectl get nodes
The connection to the server cp01:6444 was refused - did you specify the right host or port?
```

The API server itself is running normally on `cp01`, port `6443`. `kubectl` on `k8s-c1`
uses the kubeconfig file `~/.kube/config`.

1. Without using `kubectl`, show that the API server answers on `https://cp01:6443/livez`.
2. Write the wrong server URL that is currently configured in `~/.kube/config` to
   `/opt/course/f14/cause.txt`.
3. Fix `~/.kube/config` so that `kubectl get nodes` works again.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
