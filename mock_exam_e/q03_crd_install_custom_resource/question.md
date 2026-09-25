# q03 — Install a CRD and create a custom resource

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

The file `/opt/course/e03/crd.yaml` contains a CustomResourceDefinition for
`widgets.demo.example.com`.

1. Install the CRD and confirm that the API server now serves the resource in API group
   `demo.example.com`.
2. In namespace `default`, create a `Widget` named `blue-small` with `spec.color: blue` and
   `spec.size: 1`.
3. List the Widgets in `default` using the resource's short name.
4. Write the `apiVersion` you used for the Widget to `/opt/course/e03/apiversion.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
