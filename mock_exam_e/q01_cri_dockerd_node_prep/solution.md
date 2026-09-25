# q01 — Install cri-dockerd and set kernel parameters · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`worker03` 에는 Docker Engine이 이미 설치되어 있다. 이 노드는 나중에 cri-dockerd를 통해 Docker를
사용하는 클러스터에 join할 예정이다. 노드를 준비만 하고, 어떤 클러스터에도 join하지 **않는다**.

1. `/root/cri-dockerd.deb` 패키지를 `dpkg` 로 설치한다. `cri-docker.service` 와 `cri-docker.socket` 을
   enable하고 시작해서, 지금도 재부팅 후에도 둘 다 동작하게 한다.
2. 커널 모듈 `br_netfilter` 를 로드하고 부팅 시 자동으로 로드되게 한다.
3. 다음 커널 파라미터를 영구 설정하고 재부팅 없이 적용한다:
   - `net.bridge.bridge-nf-call-iptables = 1`
   - `net.ipv4.ip_forward = 1`
   - `net.netfilter.nf_conntrack_max = 131072`
4. `crictl` 로 런타임 엔드포인트 `unix:///var/run/cri-dockerd.sock` 가 응답하는지 확인한다.

## 모범 풀이

이 문제의 세 항목은 모두 **"지금 적용"과 "부팅 시 적용"을 짝으로** 해야 합니다. 한쪽만 하면 채점
시점에는 맞아 보여도 재부팅 뒤에 풀립니다.

| 항목 | 지금 적용 | 부팅 시 적용 |
|---|---|---|
| 서비스 | `systemctl start` | `systemctl enable` — 둘을 합친 것이 `enable --now` |
| 커널 모듈 | `modprobe br_netfilter` | `/etc/modules-load.d/*.conf` |
| sysctl | `sysctl --system` | `/etc/sysctl.d/*.conf` |

**1) cri-dockerd 설치와 서비스**

```bash
dpkg -i /root/cri-dockerd.deb
systemctl enable --now cri-docker.service cri-docker.socket
```

v1.24에서 dockershim이 제거된 뒤 kubelet은 Docker Engine과 직접 대화하지 못하고, cri-dockerd가 CRI
요청을 Docker API로 번역합니다. `cri-docker.socket` 이 소켓 `/run/cri-dockerd.sock` 을 열어 두고
`cri-docker.service` 가 그 요청을 처리합니다(`/var/run` 은 `/run` 을 가리키는 링크라 같은 파일입니다).

**2~3) 커널 모듈과 sysctl**

```bash
echo br_netfilter > /etc/modules-load.d/k8s.conf
modprobe br_netfilter
cat <<'EOF' > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward                = 1
net.netfilter.nf_conntrack_max     = 131072
EOF
sysctl --system
```

순서가 있습니다. `net.bridge.*` 키는 `br_netfilter` 가, `nf_conntrack_max` 는 `nf_conntrack` 모듈이
로드되어야 생깁니다. `cannot stat /proc/sys/net/netfilter/nf_conntrack_max` 가 보이면
`modprobe nf_conntrack` 을 하고 `k8s.conf`(modules-load.d)에도 추가한 뒤 `sysctl --system` 을 다시
실행합니다. `sysctl -p` 는 기본으로 `/etc/sysctl.conf` 만 읽으니 `sysctl.d` 파일에는 `--system` 을 씁니다.

**4) CRI 엔드포인트**

```bash
crictl --runtime-endpoint unix:///var/run/cri-dockerd.sock version
# RuntimeName:  docker
# RuntimeApiVersion:  v1
```

## 검증

```bash
systemctl is-enabled cri-docker.service cri-docker.socket   # enabled / enabled
systemctl is-active  cri-docker.service cri-docker.socket   # active / active
lsmod | grep br_netfilter                                   # 한 줄 이상 나와야 한다
sysctl net.bridge.bridge-nf-call-iptables net.ipv4.ip_forward net.netfilter.nf_conntrack_max
# net.bridge.bridge-nf-call-iptables = 1
# net.ipv4.ip_forward = 1
# net.netfilter.nf_conntrack_max = 131072
crictl --runtime-endpoint unix:///var/run/cri-dockerd.sock info | grep -A1 '"RuntimeReady"'
# "status": true
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 노드 준비는 "지금 + 부팅 시"의 짝이다 — `systemctl enable --now`, `modprobe` + `/etc/modules-load.d/`, `/etc/sysctl.d/` + `sysctl --system`. cri-dockerd 엔드포인트는 `unix:///var/run/cri-dockerd.sock`.
- **헷갈리는 지점**: 유닛 이름은 `cri-docker`(d 없음), 소켓 파일은 `cri-dockerd.sock`(d 있음)입니다. Docker Engine은 자체 containerd도 함께 돌리므로 노드에 containerd 소켓과 cri-dockerd 소켓이 같이 있고, 나중에 join할 때 `kubeadm join ... --cri-socket unix:///var/run/cri-dockerd.sock` 으로 어느 쪽을 쓸지 지정해야 합니다.

## 참고 문서

- 검색어: `container runtimes cri-dockerd`
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
