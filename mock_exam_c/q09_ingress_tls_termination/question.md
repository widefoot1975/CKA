# q09 — Terminate TLS at an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Servicing & Networking (20%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

An ingress controller is installed and its IngressClass is named `nginx`. Namespace
`secure` contains Deployment `portal` (3 replicas, `nginx:1.27`, port 80).

1. Expose `portal` with a ClusterIP Service `portal` on port 80.
2. Generate a self-signed certificate and key for CN `portal.example.com`, valid 365
   days, writing them to `/opt/course/q09/tls.crt` and `/opt/course/q09/tls.key`.
3. Create a TLS-type Secret `portal-tls` in namespace `secure` from those two files.
4. Create an Ingress `portal-ing` in `secure` using IngressClass `nginx` that terminates
   TLS for host `portal.example.com` with that Secret, routing path `/` (prefix) to the
   `portal` Service on port 80.
5. Verify that HTTPS to the host serves the page and that the presented certificate
   subject is `portal.example.com`.
6. State which field of the Secret the controller reads, and why the Secret must live in
   the same namespace as the Ingress.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
