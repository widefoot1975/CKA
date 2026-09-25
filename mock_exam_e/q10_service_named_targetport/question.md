# q10 — Point a Service at a named container port

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Deployment `backend` in namespace `api` runs `nginx:1.27` in a container named `nginx`, which
listens on port 80. The container spec does not declare any ports yet.

1. Add a container port `80` named `http` (protocol `TCP`) to container `nginx` of Deployment
   `backend`.
2. Create a ClusterIP Service named `backend` in namespace `api` that listens on port `8080` and
   targets the container port **by its name** `http`.
3. Confirm that the Service's EndpointSlice resolves the target to port `80`, and that
   `http://backend.api:8080` returns the nginx welcome page from a temporary `busybox:1.36` pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
