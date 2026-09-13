# q02 — Prepare a node for joining a cluster

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Context | ssh to node `worker03`, then become root |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

`worker03` has containerd, kubelet, kubeadm and kubectl installed but has never joined a
cluster. Bring it to a state where `kubeadm join` would succeed. Do **not** run the join.

1. Disable swap so that it stays off after a reboot.
2. Load the `overlay` and `br_netfilter` kernel modules and make them load at boot.
3. Set `net.bridge.bridge-nf-call-iptables=1`, `net.bridge.bridge-nf-call-ip6tables=1`
   and `net.ipv4.ip_forward=1` persistently, and apply them without rebooting.
4. Configure containerd to use the `systemd` cgroup driver, then restart it.
5. Verify the CRI endpoint `unix:///run/containerd/containerd.sock` answers, and hold
   the `kubelet`, `kubeadm` and `kubectl` packages at their current version so an
   `apt upgrade` cannot move them.
6. Write the cgroup driver reported by containerd to `/opt/q02/cgroup.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
