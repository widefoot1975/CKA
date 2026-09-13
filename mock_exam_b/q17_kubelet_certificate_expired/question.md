# q17 — Node lost after kubelet client certificate expiry

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` + ssh to node `worker02`, then become root |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

`worker02` went `NotReady`. Its kubelet is running but logs
`Unauthorized` against the API server. The control plane is healthy and every other node
is fine.

1. On `worker02`, confirm the kubelet client certificate has expired and write its
   `notAfter` date to `/opt/q17/expiry.txt`.
2. Determine whether `/etc/kubernetes/kubelet.conf` carries an embedded certificate or
   points at a rotating file under `/var/lib/kubelet/pki`. Write which, and the path, to
   `/opt/q17/identity.txt`.
3. Bring `worker02` back to `Ready` without reinstalling the node.
4. Approve any CertificateSigningRequest your fix creates, and show the node's new client
   certificate expiry.
5. Write to `/opt/q17/why.txt` why running `kubeadm certs renew all` on the control plane
   would not have fixed this.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
