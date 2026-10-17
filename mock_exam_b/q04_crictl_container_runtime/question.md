# q04 — Inspect the container runtime with crictl

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` (kubectl will not answer) |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `cp01` 에서 root 로 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다. 실행하면 이 클러스터의 `kubectl` 이 전부 멈추므로, 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**방법 A — 명령어를 복사해서 붙여 넣기** (`ssh cp01` → `sudo -i` 한 뒤)

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 보관 위치 (반드시 매니페스트 디렉터리 밖)
SOCK=unix:///run/containerd/containerd.sock

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (A17·E13 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-apiserver.yaml ] || cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml
rm -rf /opt/q04
mkdir -p /opt/q04

# 1) /etc/crictl.yaml 치우기: 처음 실행할 때만 원본을 보관한다 (원래 없었으면 표시 파일만 남긴다)
if [ ! -f $KEEP/crictl.yaml ] && [ ! -f $KEEP/crictl.yaml.absent ]; then
  if [ -f /etc/crictl.yaml ]; then mv /etc/crictl.yaml $KEEP/crictl.yaml; else touch $KEEP/crictl.yaml.absent; fi
else
  rm -f /etc/crictl.yaml       # 다시 실행: 지난번 실습에서 만든 파일을 지운다
fi

# 2) 원본 보관: kubeadm 매니페스트의 --service-cluster-ip-range 줄이 있어야 한다
cp $MAN/kube-apiserver.yaml $KEEP/kube-apiserver.yaml

# 3) 고장 내기: 플래그 이름에 s 를 붙인다 → kube-apiserver 가 "unknown flag" 로 시작하자마자 종료 (CrashLoop)
sed -i 's#- --service-cluster-ip-range=#- --service-cluster-ip-ranges=#' $MAN/kube-apiserver.yaml

# 4) 시작 상태 확인: Exited 상태의 kube-apiserver 컨테이너가 생길 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do
  crictl -r $SOCK ps -a -q --name kube-apiserver --state exited 2>/dev/null | grep -q . && break
  sleep 3
done
crictl -r $SOCK ps -a --name kube-apiserver 2>/dev/null
echo "이제 kubectl 은 응답하지 않는다. /etc/crictl.yaml 은 없다."
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
# k8s-c1 에서 (스크립트를 cp01 로 보내 root 로 실행)
ssh cp01 'sudo bash -s' < setup.sh      # 환경 만들기
ssh cp01 'sudo bash -s' < cleanup.sh    # 실습 후 정리

# 스크립트를 cp01 에 복사해 두었다면
sudo bash setup.sh
sudo bash cleanup.sh
```

설정 후 1분쯤 지나면 `kubectl` 은 `connection refused` 로 응답하지 않고, `kube-apiserver` 컨테이너가 재시작과 종료를 반복한다. `/etc/crictl.yaml` 은 없어서 `crictl` 이 엔드포인트 경고를 낸다. `/opt/q04/` 는 비어 있다.
6번(이미지 정리)은 이 노드에서 쓰지 않는 이미지를 실제로 지운다. 지워진 이미지는 나중에 필요할 때 레지스트리에서 다시 받으므로, 레지스트리에 접근할 수 없는 랩이라면 6번은 `crictl images` 로 목록만 보고 넘어간다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`kube-apiserver.yaml` 의 `--service-cluster-ip-range` 플래그 이름에 `s` 를 붙여(`--service-cluster-ip-ranges`) kube-apiserver 가 `unknown flag` 로 시작하자마자 종료하게 한다. 고장 내기 전에 원본을 `/root/.cka-setup/kube-apiserver.yaml` 에 보관한다. 원래 있던 `/etc/crictl.yaml` 은 `/root/.cka-setup/crictl.yaml` 로 옮겨 둔다(없었으면 표시 파일만 남긴다).
`cleanup.sh` 는 매니페스트를 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-apiserver` 백업 파일을 밖으로 옮기고, `/etc/crictl.yaml` 을 원래 상태로 돌려놓은 뒤 API 서버가 응답할 때까지 기다린다. A17·E13 도 같은 보관 파일을 쓰지만, 모든 setup 이 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

</details>

<details><summary>정리 명령 (방법 A, cp01 에서 root 로)</summary>

```bash
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup
mkdir -p $KEEP

# 1) setup.sh 가 보관한 원본 매니페스트로 되돌린다
if [ -f $KEEP/kube-apiserver.yaml ]; then
  cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml
  rm $KEEP/kube-apiserver.yaml
fi

# 2) 매니페스트 디렉터리 안에 남은 백업(.bak 등)은 kubelet 이 파드로 읽으므로 밖으로 옮긴다
for f in $MAN/*kube-apiserver*; do
  [ "$f" = $MAN/kube-apiserver.yaml ] || mv -v "$f" $KEEP/
done

# 3) /etc/crictl.yaml 을 원래 상태로 (원래 있었으면 원본 복원, 없었으면 실습 중 만든 파일 삭제)
if [ -f $KEEP/crictl.yaml ]; then
  mv $KEEP/crictl.yaml /etc/crictl.yaml
elif [ -f $KEEP/crictl.yaml.absent ]; then
  rm -f /etc/crictl.yaml $KEEP/crictl.yaml.absent
fi

# 4) 실습 산출물 정리
rm -rf /opt/q04

# 5) API 서버가 다시 응답할 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do kubectl get --raw /healthz >/dev/null 2>&1 && break; sleep 3; done
kubectl get --raw /healthz; echo
kubectl get nodes
```

</details>

## Task

`kubectl` on `cp01` is unusable — the API server is not answering. Work at the runtime
level with `crictl`.

1. Write `/etc/crictl.yaml` so `crictl` needs no flags: runtime and image endpoint
   `unix:///run/containerd/containerd.sock`, timeout `10`, debug off.
2. List **all** pod sandboxes on the node, including those that are not ready, and write
   the count to `/opt/q04/sandboxes.txt`.
3. Find the `kube-apiserver` container, including exited ones. Write its container ID and
   state to `/opt/q04/apiserver.txt`.
4. Write the last 20 log lines of that container to `/opt/q04/apiserver.log`.
5. From `crictl inspect`, write the container's log path on the host to
   `/opt/q04/logpath.txt`.
6. List the images on the node and remove the ones no container references.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
