# q09 — Migrate a TLS Ingress to the Gateway API

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `secure` serves Deployment `portal` (3 replicas, `nginx:1.27`, port 80) through
Service `portal` (port 80) and Ingress `portal-ing` (IngressClass `nginx`), which
terminates TLS for `portal.example.com` with Secret `portal-tls`. The Ingress NGINX
controller has been retired, so the site must move to the Gateway API. GatewayClass
`nginx` is installed and `Accepted`.

1. From the existing Ingress, write the host, the TLS Secret, and the backend Service and
   port it uses to `/opt/course/q09/ingress.txt`.
2. Create a Gateway `portal-gw` in `secure` with gatewayClassName `nginx` and one listener
   named `https`: protocol `HTTPS`, port `443`, hostname `portal.example.com`, terminating
   TLS with Secret `portal-tls`.
3. Create an HTTPRoute `portal-route` in `secure`, attached to the `https` listener, for
   hostname `portal.example.com`, sending path prefix `/` to Service `portal` on port 80.
4. Verify that HTTPS through the Gateway serves the page, that the presented certificate's
   subject is `portal.example.com`, and that the listener reports `ResolvedRefs=True` and
   `Programmed=True`.
5. Delete the Ingress only after step 4 succeeds.
6. State in one line what you would additionally need if `portal-tls` lived in namespace
   `certs` instead of `secure`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
