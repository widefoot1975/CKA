# q02 — Prepare a node for joining a cluster

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker03`, then `sudo -i` |
| Target time | 6 min |

## Setup — 사전 환경 설정

이 문제는 **아직 클러스터에 속하지 않은 노드**를 준비하는 문제다. 이미 join 된 노드는 swap 이 꺼져 있고 모듈·sysctl·
containerd 가 다 설정되어 있어서 연습이 되지 않고, 거기서 swap 을 켜면 kubelet 이 멈춘다. 그래서 클러스터와 상관없는
**빈 Ubuntu/Debian VM 하나**를 `worker03` 으로 쓴다. 스크립트는 이미 join 된 노드(`/etc/kubernetes/kubelet.conf` 가 있는
머신)에서는 실행을 거부한다.
`worker03` 에서 root(`sudo -i`)로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q02_node_prerequisites_containerd
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
sudo bash setup.sh      # 환경 만들기
sudo bash cleanup.sh    # 실습 후 정리
```

설정 직후 `worker03` 에는 containerd 가 기본 설정(`SystemdCgroup = false`)으로 돌고 있고, kubelet·kubeadm·kubectl 이
설치되어 있지만 고정(hold)되지 않았다. swap 이 켜져 있고, `/etc/modules-load.d/k8s.conf` 와 `/etc/sysctl.d/k8s.conf` 는
없다. `/opt/q02` 는 비어 있다.
kubelet 은 join 전이라 설정 파일이 없어서 몇 초마다 재시작을 반복한다. 정상이고, 이 문제와는 상관없다.
VM 에 원래 swap 이 없으면 `/swapfile-q02` 를 만들어 켠다. setup 은 실행할 때마다 `/etc/fstab` 을 처음 보관한
원본으로 되돌리므로, 실습 중 fstab 에서 바꾼 다른 내용도 함께 되돌아간다.
정리할 때 containerd 와 kubelet·kubeadm·kubectl 패키지는 남기고, 고정을 풀고 설정 파일을 지우며, `/etc/fstab` 과
`/etc/containerd/config.toml` 을 setup 이전 상태로 되돌린다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q01](../q01_ha_control_plane/question.md) · [q03 →](../q03_crd_custom_resource/question.md)
