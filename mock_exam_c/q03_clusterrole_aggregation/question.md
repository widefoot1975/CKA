# q03 — Cluster-wide permissions with ClusterRole aggregation

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 11 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A monitoring agent needs read access that is assembled from several small permission
sets, so that new capabilities can be added later without editing the role it is bound to.

1. Create ClusterRole `monitoring-aggregate`. It must carry **no rules of its own** and
   must aggregate every ClusterRole labelled
   `rbac.telco.io/aggregate-to-monitoring: "true"`.
2. Create ClusterRole `monitoring-pods` with that label, granting `get`, `list`, `watch`
   on `pods` and `pods/log` in the core API group.
3. Create ClusterRole `monitoring-nodes` with that label, granting `get`, `list` on
   `nodes` and `nodes/metrics`.
4. Create namespace `monitoring` and ServiceAccount `agent` in it, and bind
   `monitoring-aggregate` to that ServiceAccount cluster-wide.
5. Separately, the built-in `view` role must also let its subjects read
   `backups.telco.io` custom resources. Achieve this **without editing the `view`
   ClusterRole**, using a new ClusterRole named `backup-viewer`.
6. Prove the ServiceAccount can list pods in `kube-system` but cannot delete them.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
