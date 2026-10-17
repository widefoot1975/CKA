# q01 — Join a new worker node to the cluster

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh cp01` and `ssh worker03`, then `sudo -i` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **아직 클러스터에 들어가지 않은 머신**이 있어야 연습할 수 있다. 실습 클러스터에 남는 머신이 없으면
이미 join 된 워커 하나를 빼서 그 상태를 만든다. `cp01` 에서 노드를 drain 하고 Node 오브젝트를 지운 뒤,
워커에서 `kubeadm reset` 을 하면 `kubeadm`·`kubelet`·`containerd` 는 설치된 채 클러스터 설정만 사라진다.
여기에 노드 전제조건(swap, `br_netfilter`, `ip_forward`, `SystemdCgroup`)을 일부러 틀어 두면 문제의 시작 상태가 된다.

두 노드에서 차례로 root(`sudo -i`)로 실행한다. 여러 번 실행해도 안전하다. 워커 이름이 `worker03` 이 아니면
(예: `worker02`) 명령의 `worker03` 을 바꾸고, 방법 B 에서는 `sudo NODE=worker02 bash setup.sh prepare` 처럼 준다.
문제의 `worker03` 도 그 이름으로 읽는다. drain 은 `--force` 로 하므로 컨트롤러 없는 파드는 지워진다.
처음 실행할 때 워커의 원본 설정(`/etc/fstab`, `/etc/containerd/config.toml`, sysctl·모듈 설정)을
`/root/c01-backup` 에, 원래 노드 라벨을 `cp01` 의 `/root/c01-node-labels` 에 보관한다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (2단계는 무엇을 틀었는지 보여서 접어 두었다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

```bash
# 1) cp01 에서 root 로 — 원래 라벨을 보관하고, 파드를 옮기고, Node 오브젝트를 지운다
sudo -i
export KUBECONFIG=/etc/kubernetes/admin.conf
NODE=worker03
kubectl get node $NODE -o go-template='{{range $k,$v := .metadata.labels}}{{$k}}={{$v}}{{"\n"}}{{end}}' \
  | grep -Ev '^(kubernetes\.io/|beta\.kubernetes\.io/|node\.kubernetes\.io/)' > /root/c01-node-labels
kubectl drain $NODE --ignore-daemonsets --delete-emptydir-data --force
kubectl delete node $NODE
```

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
# 2) worker03 에서 root 로 — reset 하고, 원본을 보관하고, 전제조건 네 가지를 틀어 둔다
sudo -i
kubeadm reset -f
rm -rf /etc/cni/net.d/* ~/.kube
BK=/root/c01-backup
if [ ! -d $BK ]; then
  mkdir -p $BK
  cp -a /etc/fstab /etc/sysctl.d /etc/modules-load.d $BK/
  cp -a /etc/containerd/config.toml /etc/sysctl.conf $BK/ 2>/dev/null
fi

# ① swap: 256MiB 스왑 파일을 켜고 fstab 에도 등록
dd if=/dev/zero of=/swap.c01 bs=1M count=256 status=none && chmod 600 /swap.c01 && mkswap /swap.c01
swapon /swap.c01
grep -q '^/swap.c01 ' /etc/fstab || echo '/swap.c01 none swap sw 0 0' >> /etc/fstab
# ② br_netfilter: 부팅 시 로드 설정을 주석 처리하고 모듈을 내린다
sed -i -E 's/^[[:space:]]*br_netfilter/#br_netfilter/' /etc/modules-load.d/*.conf
modprobe -r br_netfilter
# ③ ip_forward: 1 로 켜는 줄을 주석 처리하고 지금 값을 0 으로
sed -i -E 's/^([[:space:]]*net\.ipv4\.ip_forward[[:space:]]*=[[:space:]]*1)/#\1/' /etc/sysctl.conf /etc/sysctl.d/*.conf
sysctl -w net.ipv4.ip_forward=0
# ④ SystemdCgroup: true → false
sed -i 's/SystemdCgroup *= *true/SystemdCgroup = false/' /etc/containerd/config.toml
systemctl restart containerd
```

</details>

```bash
# 3) 시작 상태 확인
kubectl get nodes                                   # (cp01) worker03 이 목록에 없다
ls /etc/kubernetes/kubelet.conf; swapon --show      # (worker03) kubelet.conf 없음, 스왑 켜짐
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
sudo bash setup.sh prepare    # cp01 에서 — 라벨 보관, drain, Node 삭제
sudo bash setup.sh fail       # worker03 에서 — yes 를 입력하면 reset 하고 전제조건을 틀어 둔다
sudo bash cleanup.sh worker   # worker03 에서 — 실습 후, 원본 설정 복원 (먼저)
sudo bash cleanup.sh cp       # cp01 에서 — 그다음, 테스트 파드 삭제·라벨 원복 (join 전이면 join 명령을 만들어 준다)
```

설정 직후 `cp01` 의 `kubectl get nodes` 에는 `worker03` 이 없고, `worker03` 에는 `/etc/kubernetes/kubelet.conf` 가
없다. kubelet 은 설정 파일이 없어 멈춰 있거나 재시작을 반복하는데, join 전에는 정상이다.
`kubeadm token list` 는 비어 있거나 기존 토큰만 보일 수 있다. 만료된 토큰은 컨트롤러 매니저의 tokencleaner 가
곧 지우므로, 목록에 남아 있지 않아도 문제의 전제("기존 토큰은 쓰지 않는다")와 다르지 않다.
`SystemdCgroup` 줄이 아예 없는 containerd 설정이면 ④ 는 바뀌지 않는다. 그 경우 풀이 1) 의 `containerd config default`
단계가 바로 연습 대상이다.
문제를 끝까지 풀었어도 **`cleanup.sh worker` → `cleanup.sh cp` 순서로 실행**한다. 보관한 원본 설정과 원래 라벨로
되돌리고 setup 이 만든 스왑 파일을 지운다. 중간에 그만뒀다면 `cleanup.sh cp` 가 다시 join 할 명령을 출력한다.

<details><summary>정리 명령 (방법 A) — worker03 먼저, 그다음 cp01</summary>

```bash
# worker03 에서 root 로 — 원본 설정 복원
BK=/root/c01-backup
swapoff /swap.c01; rm -f /swap.c01
cp -a $BK/fstab /etc/fstab
cp -a $BK/modules-load.d/. /etc/modules-load.d/
cp -a $BK/sysctl.d/. /etc/sysctl.d/
[ -f $BK/sysctl.conf ] && cp -a $BK/sysctl.conf /etc/sysctl.conf
modprobe br_netfilter && sysctl --system
cp -a $BK/config.toml /etc/containerd/config.toml && systemctl restart containerd
rm -rf $BK
```

```bash
# cp01 에서 root 로 — 테스트 파드와 라벨 정리
kubectl delete pod t1 --ignore-not-found
kubectl label node worker03 node-role.kubernetes.io/worker-     # 원래 이 라벨이 없었다면
while read -r kv; do kubectl label node worker03 "$kv" --overwrite; done < /root/c01-node-labels
rm -f /root/c01-node-labels
# join 을 못 하고 그만뒀다면: 아래 출력을 worker03 에서 "kubeadm reset -f && <출력>" 으로 실행한 뒤 위 두 줄을 한다
kubeadm token create --print-join-command
```

</details>

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
