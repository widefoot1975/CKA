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

## Setup — 사전 환경 설정

이 문제는 **아직 클러스터에 속하지 않은 노드**를 준비하는 문제다. 이미 클러스터에 들어 있는 노드에는
`br_netfilter`·sysctl 이 설정되어 있고 containerd 가 돌고 있어서, 거기서 풀면 연습이 되지 않고 Docker 를
설치하다 노드가 망가질 수도 있다. 그래서 클러스터와 상관없는 **빈 Ubuntu/Debian VM 하나**를 `worker03` 으로
쓴다. 스크립트는 kubelet 이 도는 머신에서는 실행을 거부한다.
`worker03` 에서 root(`sudo -i`)로 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) worker03(빈 VM) 에서 root 로
sudo -i
ARCH=$(dpkg --print-architecture)            # amd64 / arm64

# 1) Docker Engine (문제의 전제 조건) 과 crictl — 없을 때만 설치
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh
command -v crictl >/dev/null || curl -fsSL \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.35.0/crictl-v1.35.0-linux-$ARCH.tar.gz \
  | tar -xz -C /usr/local/bin crictl

# 2) 지난 실습 흔적 정리: cri-dockerd 패키지, 모듈·sysctl 설정 파일
systemctl disable --now cri-docker.service cri-docker.socket 2>/dev/null
dpkg -P cri-dockerd 2>/dev/null
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/k8s.conf
modprobe -r br_netfilter 2>/dev/null
sysctl -qw net.netfilter.nf_conntrack_max=65536 2>/dev/null

# 3) /root/cri-dockerd.deb 만들기 — 공식 바이너리와 공식 systemd 유닛을 .deb 하나로 묶는다
V=0.3.16; W=$(mktemp -d)
curl -fsSL https://github.com/Mirantis/cri-dockerd/releases/download/v$V/cri-dockerd-$V.$ARCH.tgz | tar -xz -C $W
mkdir -p $W/pkg/DEBIAN $W/pkg/usr/bin $W/pkg/lib/systemd/system
install -m 0755 $W/cri-dockerd/cri-dockerd $W/pkg/usr/bin/
for u in cri-docker.service cri-docker.socket; do
  curl -fsSL https://raw.githubusercontent.com/Mirantis/cri-dockerd/v$V/packaging/systemd/$u -o $W/pkg/lib/systemd/system/$u
done
printf 'Package: cri-dockerd\nVersion: %s\nArchitecture: %s\nMaintainer: CKA practice <none@example.com>\nDescription: cri-dockerd (CKA practice package)\n' \
  $V $ARCH > $W/pkg/DEBIAN/control
dpkg-deb --build --root-owner-group $W/pkg /root/cri-dockerd.deb
rm -rf $W

# 4) 시작 상태 확인: Docker 동작, .deb 준비, cri-dockerd 미설치, k8s 설정 파일 없음
docker version --format 'Docker {{.Server.Version}}'
ls -l /root/cri-dockerd.deb
systemctl status cri-docker.service 2>&1 | head -1      # could not be found
ls /etc/modules-load.d/ /etc/sysctl.d/
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

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

<details><summary>정리 명령 (방법 A)</summary>

```bash
systemctl disable --now cri-docker.service cri-docker.socket
dpkg -P cri-dockerd
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/k8s.conf /root/cri-dockerd.deb
sysctl --system
```

</details>

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
