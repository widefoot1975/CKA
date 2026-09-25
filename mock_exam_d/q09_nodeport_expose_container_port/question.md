# q09 — Publish a container port with a NodePort Service

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `spline` contains Deployment `front-end` (image `nginx:1.27`, container name `nginx`).
Its pod template does not declare any container ports.

1. Update the Deployment so that container `nginx` declares containerPort `80`, named `http`,
   protocol `TCP`.
2. Create a Service `front-end-svc` of type `NodePort` in `spline` that selects the `front-end`
   pods and maps port `80` to targetPort `80`, using the fixed nodePort `30080`.
3. Verify that the Service has endpoints and that `http://<node IP>:30080` returns the nginx
   welcome page.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
