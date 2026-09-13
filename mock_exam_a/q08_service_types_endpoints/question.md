# q08 — Service types and endpoint inspection

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Servicing & Networking (20%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `shop` needs the same set of pods reachable four different ways.

1. Create a Deployment `api` in `shop` with 3 replicas of `nginx:1.27`, container port 80.
2. Create a ClusterIP Service `api-clusterip` on port 8080 forwarding to container port 80.
3. Create a NodePort Service `api-nodeport`, service port 8080, target port 80, fixed node
   port 31080.
4. Create a headless Service `api-headless` for the same pods on port 8080.
5. Create a LoadBalancer Service `api-lb` on port 80 and record its `EXTERNAL-IP`.
6. List the three backing pod IPs of `api-clusterip`, once through its Endpoints and once
   through its EndpointSlice.
7. Reach `api-clusterip` from a temporary pod and `api-nodeport` from a node, and state in
   one line what `EXTERNAL-IP` shows for `api-lb` and why.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
