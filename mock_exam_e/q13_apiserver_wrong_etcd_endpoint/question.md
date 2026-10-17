# q13 — API server down after a machine migration

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c2` → `ssh cp01`, then `sudo -i` |
| Target time | 9 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `cp01` 에서 root 로 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**방법 A — 명령어를 복사해서 붙여 넣기** (`ssh cp01` → `sudo -i` 한 뒤)

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 매니페스트 보관 위치 (반드시 매니페스트 디렉터리 밖)

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (A17 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-apiserver.yaml ] || cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml
rm -rf /opt/course/e13
mkdir -p /opt/course/e13

# 1) 원래 값 확인 (kubeadm stacked etcd 라면 https://127.0.0.1:2379) 후 원본 보관
ORIG=$(grep -o -- '--etcd-servers=[^ ]*' $MAN/kube-apiserver.yaml | cut -d= -f2)
echo "원래 --etcd-servers: $ORIG"
[ "$ORIG" = https://127.0.0.1:2379 ] || echo "주의: 127.0.0.1 이 아닙니다. 풀 때는 원래 값($ORIG)으로 되돌려야 합니다."
cp $MAN/kube-apiserver.yaml $KEEP/kube-apiserver.yaml

# 2) 고장 내기: 옛 머신 주소로 바꾼다 (이 노드의 주소와 겹치면 다른 값을 쓴다)
OLD=10.0.5.20
hostname -I | tr ' ' '\n' | grep -qx $OLD && OLD=10.0.6.20
sed -i "s#--etcd-servers=.*#--etcd-servers=https://$OLD:2379#" $MAN/kube-apiserver.yaml

# 3) 시작 상태 확인: 1~2분 뒤 kubectl 은 connection refused, crictl ps -a 에 Exited kube-apiserver
grep -n -- '--etcd-servers' $MAN/kube-apiserver.yaml
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
# k8s-c2 에서 (스크립트를 cp01 로 보내 root 로 실행)
ssh cp01 'sudo bash -s' < setup.sh      # 환경 만들기
ssh cp01 'sudo bash -s' < cleanup.sh    # 실습 후 정리

# 스크립트를 cp01 에 복사해 두었다면
sudo bash setup.sh
sudo bash cleanup.sh
```

**실행하면 이 클러스터의 `kubectl` 이 전부 멈춘다.** 문제를 풀거나 `cleanup.sh` 를 돌려야 돌아온다. 연습 랩에서는 `k8s-c2` 를 따로 만들 필요 없이 평소 쓰는 클러스터의 컨트롤 플레인 노드에서 하면 된다. 단일 노드가 아니어도 풀이는 같다.
설정 후 1~2분 뒤 `kubectl` 이 `connection refused` 로 실패하기 시작한다. `/opt/course/e13/` 는 비어 있다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

kube-apiserver 매니페스트의 `--etcd-servers` 를 옛 머신 주소 `https://10.0.5.20:2379` 로 바꾼다(노드 주소와 겹치면 `10.0.6.20`). 원래 값이 `https://127.0.0.1:2379` 가 아니면 스크립트가 원래 값을 출력하고, 그 경우 그 값으로 되돌리는 것이 정답이다.
고장 내기 전에 원본을 `/root/.cka-setup/kube-apiserver.yaml` 에 보관한다. `cleanup.sh` 는 그 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-apiserver` 백업 파일을 밖으로 옮긴 뒤 API 서버가 다시 응답할 때까지 기다린다. A17 도 같은 파일을 쓰지만, 두 setup 모두 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

</details>

<details><summary>정리 명령 (방법 A, cp01 에서 root 로)</summary>

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup
mkdir -p $KEEP

# 1) setup.sh 가 보관한 원본으로 되돌린다
if [ -f $KEEP/kube-apiserver.yaml ]; then
  cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml
  rm $KEEP/kube-apiserver.yaml
fi

# 2) 매니페스트 디렉터리 안에 남은 백업(.bak 등)은 kubelet 이 파드로 읽으므로 밖으로 옮긴다
for f in $MAN/*kube-apiserver*; do
  [ "$f" = $MAN/kube-apiserver.yaml ] || mv -v "$f" $KEEP/
done

# 3) 실습 산출물 정리
rm -rf /opt/course/e13

# 4) API 서버가 다시 응답할 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do kubectl get --raw /healthz >/dev/null 2>&1 && break; sleep 3; done
kubectl get --raw /healthz; echo
kubectl get nodes
```

</details>

## Task

The single-node cluster `k8s-c2` was moved to a new machine, `cp01`. Since the move, every
`kubectl` command fails with `The connection to the server ... was refused`. etcd and the kubelet
on `cp01` are running normally.

1. On `cp01`, find out why kube-apiserver does not stay up. Use the container runtime and the
   static pod manifest; `kubectl` cannot help until the API server works.
2. Fix the kube-apiserver static pod manifest. Keep a backup copy of the original file outside
   `/etc/kubernetes/manifests`.
3. Write the wrong setting value you found to `/opt/course/e13/cause.txt`.
4. Confirm that `kubectl get nodes` works again and shows `cp01` as `Ready`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
