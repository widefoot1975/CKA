# q03 — Upgrade one worker node with kubeadm

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c2` → `ssh worker01`, then `sudo -i` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 "컨트롤 플레인은 새 버전, `worker01` 만 한 마이너 낮은 버전"인 상태에서 시작한다. 실습
클러스터는 보통 모든 노드가 같은 버전이므로, `worker01` 의 `kubeadm`·`kubelet`·`kubectl` 을 한 마이너
**내려서** 그 상태를 만든다. 문제의 v1.35/v1.34 는 예시이고, 스크립트는 지금 컨트롤 플레인 버전을 읽어서
그보다 한 마이너 낮은 버전으로 맞춘다.
`worker01` 에서 root(`sudo -i`)로 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) worker01 에서 root 로
sudo -i

# 1) 컨트롤 플레인 버전 확인 → CUR(예: 1.35) 와 한 마이너 낮은 PREV(예: 1.34)
CP=$(kubectl --kubeconfig /etc/kubernetes/kubelet.conf get --raw /version \
     | grep -o '"gitVersion": *"v[0-9.]*' | grep -o '[0-9][0-9.]*')
CUR=$(echo $CP | cut -d. -f1,2); PREV=$(echo $CUR | awk -F. '{printf "%d.%d", $1, $2-1}')
echo "control plane v$CP / worker01 → v$PREV"

# 2) 저장소를 v$PREV 로 바꾸고 세 패키지를 그 버전으로 내린다
sed -i -E "s#core:/stable:/v[0-9]+\.[0-9]+/#core:/stable:/v$PREV/#" /etc/apt/sources.list.d/kubernetes.list
apt-get update -qq
OLD=$(apt-cache madison kubeadm | awk '{print $3}' | grep "^$PREV\." | head -1)
apt-mark unhold kubeadm kubelet kubectl
apt-get install -y --allow-downgrades kubeadm=$OLD kubelet=$OLD kubectl=$OLD
apt-mark hold kubeadm kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet

# 3) 문제의 시작 조건: 저장소는 이미 v$CUR 을 가리키고 apt update 도 끝난 상태
sed -i -E "s#core:/stable:/v[0-9]+\.[0-9]+/#core:/stable:/v$CUR/#" /etc/apt/sources.list.d/kubernetes.list
apt-get update -qq

# 4) 시작 상태 확인
kubeadm version -o short; kubelet --version; apt-mark showhold
```

```bash
# k8s-c2 에서 — worker01 VERSION 이 한 마이너 낮고 Ready 인지 확인
kubectl get nodes
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
sudo bash setup.sh      # worker01 에서 — 환경 만들기
sudo bash cleanup.sh    # worker01 에서 — 중간에 그만뒀을 때만, 원래 버전으로 되돌리기
```

설정 직후 `worker01` 은 컨트롤 플레인보다 한 마이너 낮은 버전으로 `Ready` 이고, 세 패키지는 `hold` 상태,
저장소 파일은 컨트롤 플레인 버전을 가리킨다. 문제를 끝까지 풀면 처음 상태로 돌아오므로 정리할 것이 없다.
kubelet 은 API 서버보다 세 마이너까지 낮아도 되므로(version skew 정책) 버전을 내려도 노드는 정상 동작한다.
`/var/lib/kubelet/config.yaml` 은 새 버전 kubeadm 이 쓴 그대로라, 옛 kubelet 이 모르는 필드가 있으면
로그에 경고가 남을 수 있다. `systemctl status kubelet` 이 `active (running)` 이면 무시해도 된다.
저장소 주소가 `pkgs.k8s.io` 가 아니거나(옛 `apt.kubernetes.io` 등) 파일 이름이 다르면 2)·3) 의 경로를 자기
환경에 맞게 고친다.

<details><summary>정리 명령 (방법 A) — 중간에 그만뒀을 때만</summary>

```bash
# worker01 에서 root 로 — 컨트롤 플레인 버전으로 다시 올린다
CP=$(kubectl --kubeconfig /etc/kubernetes/kubelet.conf get --raw /version \
     | grep -o '"gitVersion": *"v[0-9.]*' | grep -o '[0-9][0-9.]*')
NEW=$(apt-cache madison kubeadm | awk '{print $3}' | grep "^$CP-" | head -1)
apt-mark unhold kubeadm kubelet kubectl
apt-get install -y kubeadm=$NEW kubelet=$NEW kubectl=$NEW
apt-mark hold kubeadm kubelet kubectl
kubeadm upgrade node
systemctl daemon-reload && systemctl restart kubelet
```

```bash
# k8s-c2 에서 — drain 한 채 그만뒀다면
kubectl uncordon worker01
```

</details>

## Task

The control plane of cluster `k8s-c2` already runs Kubernetes v1.35.x, but node `worker01`
still runs v1.34. On `worker01` the apt repository already points to the Kubernetes v1.35
packages and `apt update` has already been run. Run `kubectl` commands from `k8s-c2`.

1. On `worker01`, upgrade `kubeadm` to exactly the version the control plane runs, then
   run the `kubeadm` upgrade step for a worker node.
2. Drain `worker01`. Then upgrade `kubelet` and `kubectl` on `worker01` to the same
   version and restart the kubelet.
3. Make `worker01` schedulable again and confirm that `kubectl get nodes` shows it `Ready`
   with the new version.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
