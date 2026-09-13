# q16 — A control plane component is not running

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` + ssh to node `cp01`, then become root |
| Target time | 10 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Newly created pods stay `Pending` forever with no scheduling events. Existing pods keep
running and `kubectl` works normally.

1. Identify which control plane component is failing and write its name to
   `/opt/q16/component.txt`.
2. On `cp01`, find the reason using the container runtime and the kubelet journal, since
   the component's pod does not appear in `kubectl get pods -n kube-system`. Write the
   decisive log line to `/opt/q16/log.txt`.
3. Repair the component. Do not delete anything under `/etc/kubernetes/pki`.
4. Confirm a new pod schedules and the component is `Running` and `1/1`.
5. Write to `/opt/q16/why.txt` where this component's manifest lives and why
   `kubectl delete pod` is not how you restart it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
