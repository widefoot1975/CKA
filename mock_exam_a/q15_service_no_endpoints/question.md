# q15 — A Service with no endpoints

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Service `api-svc` in namespace `shop` accepts connections but every client gets
`connection refused`. Three pods of Deployment `api` are running.

1. Show that the Service has no endpoints, once through its Endpoints object and once
   through its EndpointSlice.
2. Compare the Service selector against the labels actually present on the pods.
3. Report whether the pods are `Ready`.
4. Compare the Service `targetPort` against the port the container actually listens on.
5. Fix the Service so three endpoints appear. Do not relabel, restart or recreate the pods.
6. Write in one line the two independent reasons an endpoint list can be empty.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
