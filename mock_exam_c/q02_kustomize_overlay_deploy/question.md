# q02 — Deploy an environment overlay with Kustomize

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 11 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A base manifest set exists at `/opt/course/q02/base/` containing `deployment.yaml`
(Deployment `web`, image `nginx:1.25`, 1 replica), `service.yaml` and
`kustomization.yaml`.

Build a production overlay at `/opt/course/q02/overlays/prod/` that, without editing
any file under `base/`:

1. References the base.
2. Deploys into namespace `prod-web` (create the namespace).
3. Prefixes every resource name with `prod-`.
4. Adds the label `env: prod` to every resource.
5. Sets the `web` Deployment to 4 replicas.
6. Changes the image to `nginx:1.27`.
7. Adds a ConfigMap generated from literals `TIER=prod` and `LOG_LEVEL=warn`,
   named `web-config`.
8. Patches the container port to `8080` using a patch with an explicit `target`.

Render the overlay to stdout to review it **before** applying, then apply it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
