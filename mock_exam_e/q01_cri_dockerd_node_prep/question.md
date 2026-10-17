# q01 — Install cri-dockerd and set kernel parameters

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh worker03`, then `sudo -i` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **아직 클러스터에 속하지 않은 노드**를 준비하는 문제다. 이미 클러스터에 들어 있는 노드에는
`br_netfilter`·sysctl 이 설정되어 있고 containerd 가 돌고 있어서, 거기서 풀면 연습이 되지 않고 Docker 를
설치하다 노드가 망가질 수도 있다. 그래서 클러스터와 상관없는 **빈 Ubuntu/Debian VM 하나**를 `worker03` 으로
쓴다. 스크립트는 kubelet 이 도는 머신에서는 실행을 거부한다.
`worker03` 에서 root(`sudo -i`)로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q01_cri_dockerd_node_prep
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
sudo bash setup.sh      # 환경 만들기
sudo bash cleanup.sh    # 실습 후 정리
```

설정 직후 `worker03` 에는 Docker Engine 이 돌고 있고, `/root/cri-dockerd.deb` 가 있으며, cri-dockerd 는 아직
설치되지 않았다. `/etc/modules-load.d/k8s.conf` 와 `/etc/sysctl.d/k8s.conf` 도 없다.
공식 릴리스의 `.deb` 는 배포판 코드명(jammy, bookworm 등)마다 파일이 따로 있어서, 어느 Ubuntu/Debian 에서나
쓰도록 공식 바이너리와 유닛 파일을 `.deb` 로 직접 묶었다. 문제 풀이(`dpkg -i`)는 공식 패키지와 똑같다.
Docker 가 돌면서 `ip_forward` 를 이미 1 로 켜 두고 `br_netfilter` 를 쓰고 있을 수 있다. 지금 값이 맞아 보여도
**재부팅 뒤에도 유지되는 설정 파일**을 만드는 것이 이 문제의 요점이다.
정리할 때 Docker 와 crictl 은 남기고 cri-dockerd 와 설정 파일만 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [q02 →](../q02_kustomize_overlay_basic/question.md)
