# q01 — Install and upgrade a Helm release

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The team wants the `podinfo` demo application installed with Helm. The chart version must be
pinned so that every later change uses exactly the same chart.

1. Add the chart repository `podinfo` at `https://stefanprodan.github.io/podinfo`, refresh the
   repository index, and write the latest version of chart `podinfo/podinfo` shown by
   `helm search repo` to `/opt/course/d01/version.txt`.
2. Install release `podinfo` from chart `podinfo/podinfo` into namespace `demo` (create the
   namespace), passing exactly that version with `--version` and setting `replicaCount=2`.
3. Upgrade the release, with the same chart version, to set `ui.message=hello-cka` without
   losing the `replicaCount` set in step 2.
4. Confirm that the release history shows 2 revisions and that the release's Deployment runs
   2 ready pods.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
