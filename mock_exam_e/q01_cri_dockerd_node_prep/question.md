# q01 — Install cri-dockerd and set kernel parameters

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh worker03`, then `sudo -i` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Docker Engine is already installed on `worker03`. The node will later join a cluster that uses
Docker through cri-dockerd. Prepare the node, but do **not** join it to any cluster.

1. Install the package `/root/cri-dockerd.deb` with `dpkg`. Enable and start
   `cri-docker.service` and `cri-docker.socket` so that both are running now and after a reboot.
2. Load the kernel module `br_netfilter` and make it load automatically at boot.
3. Set these kernel parameters persistently and apply them without rebooting:
   - `net.bridge.bridge-nf-call-iptables = 1`
   - `net.ipv4.ip_forward = 1`
   - `net.netfilter.nf_conntrack_max = 131072`
4. Verify with `crictl` that the runtime endpoint `unix:///var/run/cri-dockerd.sock` answers.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
