# q01 — Render and install a chart without its CRDs

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The Argo CD CustomResourceDefinitions (`*.argoproj.io`) are already installed in the
cluster and are managed outside of Helm. Argo CD itself must now be installed with Helm,
without the chart creating or managing those CRDs.

1. Add the chart repository `https://argoproj.github.io/argo-helm` with the name `argo`.
   Write the latest version of chart `argo/argo-cd` shown by `helm search repo` to
   `/opt/course/f01/version.txt`, and use exactly that version in the next steps.
2. Render the chart with `helm template` using release name `argocd`, namespace `argocd`
   and the value `crds.install=false`. Save the output to `/opt/course/f01/argocd.yaml`.
3. Install release `argocd` into namespace `argocd` (create the namespace) with the same
   chart version and the same value.
4. Confirm that `/opt/course/f01/argocd.yaml` contains no `kind: CustomResourceDefinition`
   and that `helm list -n argocd` shows the release as `deployed`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
