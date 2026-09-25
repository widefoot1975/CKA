# q02 — Apply a Kustomize overlay

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A Kustomize base for the application `api` exists in `/opt/course/e02/base/`: Deployment `api`
(image `nginx:1.27`, 1 replica), Service `api` and a `kustomization.yaml`. Do not modify any file
under `base/`.

1. Create `/opt/course/e02/overlays/staging/kustomization.yaml` that uses the base and
   - places all resources in namespace `staging`,
   - sets Deployment `api` to `2` replicas,
   - changes the image `nginx` to `nginx:1.28`,
   - adds the label `env: staging` to all resources **without** changing any selector.
2. Create namespace `staging` and render the overlay with `kubectl kustomize` to check it.
3. Apply the overlay with `kubectl apply -k` and confirm that Deployment `api` in `staging` has
   2 ready replicas running `nginx:1.28`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
