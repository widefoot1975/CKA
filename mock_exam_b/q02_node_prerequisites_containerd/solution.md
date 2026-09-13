# q02 — Prepare a node for joining a cluster · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`worker03` 에는 containerd, kubelet, kubeadm, kubectl이 설치되어 있지만 클러스터에 join한 적이
없다. `kubeadm join` 이 성공할 수 있는 상태로 만든다. join은 실행하지 **않는다**.

1. 재부팅 후에도 swap이 꺼져 있게 만든다.
2. `overlay` 와 `br_netfilter` 커널 모듈을 로드하고 부팅 시에도 로드되게 한다.
3. `net.bridge.bridge-nf-call-iptables=1`, `net.bridge.bridge-nf-call-ip6tables=1`,
   `net.ipv4.ip_forward=1` 을 영구 설정하고 재부팅 없이 적용한다.
4. containerd가 `systemd` cgroup 드라이버를 쓰게 설정하고 재시작한다.
5. CRI 엔드포인트 `unix:///run/containerd/containerd.sock` 가 응답하는지 확인하고,
   `kubelet`, `kubeadm`, `kubectl` 패키지를 현재 버전에 고정해 `apt upgrade` 가 못 움직이게 한다.
6. containerd가 보고하는 cgroup 드라이버를 `/opt/q02/cgroup.txt` 에 적는다.

## 모범 풀이

**1) swap.** 현재 세션과 영구 설정 두 곳을 모두 건드려야 합니다.

```bash
swapoff -a
sed -i '/\sswap\s/s/^/#/' /etc/fstab
# systemd 가 만든 swap 유닛이 있는 배포판은 이것도 필요하다
systemctl list-units --type=swap --all
systemctl mask <name>.swap
```

**2) 모듈**

```bash
cat <<'EOF' >/etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
```

**3) sysctl**

```bash
cat <<'EOF' >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system
```

`br_netfilter` 를 먼저 로드하지 않으면 `net.bridge.*` 키 자체가 존재하지 않아
`sysctl --system` 이 `cannot stat /proc/sys/net/bridge/...` 로 실패합니다. 순서가 있습니다.

**4) containerd cgroup 드라이버.** 여기가 이 문제의 핵심입니다. 설정 키 경로를 외워서 붙여넣지
말고, 현재 containerd가 만들어주는 기본 설정을 받아 그 안에서 고칩니다. containerd 2.x는 플러그인
이름이 `io.containerd.grpc.v1.cri` 에서 `io.containerd.cri.v1.runtime` 으로 바뀌었기 때문에
외운 경로가 틀리면 아무 효과 없이 조용히 무시됩니다.

```bash
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
grep -n 'SystemdCgroup' /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
```

kubelet의 기본 cgroup 드라이버도 `systemd` 입니다(`/var/lib/kubelet/config.yaml` 의
`cgroupDriver`). 두 쪽이 다르면 파드가 뜨긴 하지만 리소스 제한이 엉뚱한 cgroup에 걸려
메모리 압박 상황에서 노드가 불안정해집니다. 즉시 에러가 안 나므로 찾기 어렵습니다.

**5) 엔드포인트 확인과 패키지 고정**

```bash
crictl --runtime-endpoint unix:///run/containerd/containerd.sock version
apt-mark hold kubelet kubeadm kubectl
apt-mark showhold
```

**6)**

```bash
crictl info | grep -i systemdCgroup     # true
echo systemd > /opt/q02/cgroup.txt
```

## 검증

```bash
swapon --show                    # 출력이 비어 있어야 한다
lsmod | grep -E 'br_netfilter|overlay'
sysctl net.ipv4.ip_forward net.bridge.bridge-nf-call-iptables   # 둘 다 = 1
systemctl is-active containerd   # active
crictl info | grep -i cgroup     # SystemdCgroup: true
apt-mark showhold                # kubeadm kubectl kubelet
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `containerd config default > /etc/containerd/config.toml` 로 기본 설정을 생성한 뒤 `SystemdCgroup = true` 로 바꾸고 재시작한다. 경로를 기억에서 타이핑하지 않는다.
- **헷갈리는 지점**: `swapoff -a` 는 지금만 끄고 `/etc/fstab` 주석은 다음 부팅부터 적용됩니다. 둘 중 하나만 하면 채점 시점에는 통과하고 재부팅 후 kubelet이 죽습니다. `br_netfilter` 로드는 sysctl 설정보다 먼저여야 합니다.

## 참고 문서

- 검색어: `container runtimes`
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
