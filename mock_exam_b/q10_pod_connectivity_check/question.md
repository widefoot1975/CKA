# q10 — Verify pod-to-pod connectivity across namespaces

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Servicing & Networking (20%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A team claims pods in one namespace cannot talk to a service in another. Prove or
disprove it.

1. In namespace `alpha`, create deployment `alpha-web` (`nginx:1.27`, 2 replicas) and
   expose it as a ClusterIP service `alpha-web` on port `80`.
2. In namespace `beta`, create a long-running pod named `probe` using image
   `busybox:1.36` that does not restart.
3. From `probe`, resolve `alpha-web` using its **short name** and then its FQDN. Write
   both results and the resolved ClusterIP to `/opt/q10/dns.txt`.
4. Write the pod IPs currently backing the service, read from the EndpointSlice, to
   `/opt/q10/endpoints.txt`, then show an HTTP request from `probe` actually succeeding.
5. Write to `/opt/q10/triage.txt` the one decisive command for each of the three layers
   that can break this: DNS, Service/EndpointSlice, NetworkPolicy.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
