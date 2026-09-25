# q04 — Check and renew a control plane certificate

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

The cluster was built with kubeadm. The security team wants the API server's serving
certificate renewed now, without touching any other certificate. Work on `cp01` and write the
answer files there.

1. Save the output of `kubeadm certs check-expiration` to `/opt/course/d04/before.txt`.
2. Renew only the `apiserver` certificate using kubeadm.
3. Make the running kube-apiserver load the renewed certificate.
4. Write the new expiry date (`notAfter`) of `/etc/kubernetes/pki/apiserver.crt`, as printed by
   `openssl`, to `/opt/course/d04/apiserver-enddate.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
