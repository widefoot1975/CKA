# q04 — Create a kubeconfig for a certificate-based user

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 9 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A new operator `jane` must reach the cluster with her own client certificate.

1. Generate a 2048-bit RSA key `/root/jane.key` and a CSR `/root/jane.csr` with subject
   `CN=jane`, `O=dev-team`.
2. Submit it as a CertificateSigningRequest `jane` — signer
   `kubernetes.io/kube-apiserver-client`, usage `client auth`, one day of validity. Approve
   it and save the issued certificate to `/root/jane.crt`.
3. Build a standalone kubeconfig `/root/jane.kubeconfig`: cluster `k8s-c1` with the admin
   kubeconfig's endpoint and CA, user `jane`, current context `jane@k8s-c1`, certs embedded.
4. Grant `jane` `get`, `list` and `watch` on `pods` in `dev` with a Role `pod-reader` and a
   RoleBinding `jane-pod-reader`.
5. With only `/root/jane.kubeconfig`, show `jane` lists pods in `dev` and not in `default`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
