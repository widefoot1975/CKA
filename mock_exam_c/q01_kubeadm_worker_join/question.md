# q01 — Join a new worker node to the cluster

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Context | `kubectl config use-context k8s-c1` + ssh to `cp01` and `worker03`, then become root |
| Target time | 12 min |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

A freshly provisioned machine `worker03` has `kubeadm`, `kubelet` and `containerd`
installed but has never joined a cluster. Bring it into the cluster as a worker.

1. On `worker03`, confirm the node prerequisites are met: swap disabled, the
   `br_netfilter` module loaded, `net.ipv4.ip_forward` set to `1`, and containerd's
   runc using `SystemdCgroup = true`. Fix anything that is wrong.
2. On `cp01`, list the existing bootstrap tokens. The old ones have expired — do not
   reuse them.
3. Produce a valid join command on `cp01` without hand-assembling it.
4. Also compute the discovery CA certificate hash from `/etc/kubernetes/pki/ca.crt`
   manually and confirm it matches the hash inside the join command.
5. Run the join on `worker03` and label the node
   `node-role.kubernetes.io/worker=worker`.
6. Confirm `worker03` reaches `Ready` and that a test pod can be scheduled onto it.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
