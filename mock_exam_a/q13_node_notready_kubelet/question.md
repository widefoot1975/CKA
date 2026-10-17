# q13 — Recover a NotReady node

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh worker01`, then `sudo -i` |
| Target time | 9 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `worker01` 에서 root 로 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**방법 A — 명령어를 복사해서 붙여 넣기** (`ssh worker01` → `sudo -i` 한 뒤)

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
CFG=/var/lib/kubelet/config.yaml
KEEP=/root/.cka-setup          # 원본 설정 보관 위치

# 1) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌리고, 없으면 지금 원본을 보관한다
mkdir -p $KEEP
if [ -f $KEEP/a13-kubelet-config.yaml ]; then
  cp -p $KEEP/a13-kubelet-config.yaml $CFG
else
  cp -p $CFG $KEEP/a13-kubelet-config.yaml
fi

# 2) 고장 내기 ("동료의 수정"): client CA 파일 경로 끝에 글자를 하나 붙인다 → kubelet 이 시작하자마자 종료
sed -i 's#clientCAFile: /etc/kubernetes/pki/ca.crt$#clientCAFile: /etc/kubernetes/pki/ca.crtx#' $CFG
systemctl enable kubelet
systemctl restart kubelet || true

# 3) 시작 상태 확인: kubelet 은 activating (auto-restart) 을 반복, containerd 는 active.
#    약 1분 뒤 k8s-c1 에서 worker01 이 NotReady 로 바뀐다
sleep 5
systemctl is-active kubelet || true
systemctl is-active containerd || true
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
# k8s-c1 에서 (스크립트를 worker01 로 보내 root 로 실행)
ssh worker01 'sudo bash -s' < setup.sh      # 환경 만들기
ssh worker01 'sudo bash -s' < cleanup.sh    # 실습 후 정리

# 스크립트를 worker01 에 복사해 두었다면
sudo bash setup.sh
sudo bash cleanup.sh
```

설정 후 40초~1분쯤 지나면 `k8s-c1` 에서 `kubectl get nodes` 로 `worker01` 이 `NotReady` 로 보인다. 그때부터 푼다. 그 노드에 있던 파드가 `Terminating` 으로 바뀌는 것은 약 5분 뒤(unreachable taint 의 기본 toleration 300초)라서, 바로 풀기 시작하면 아직 `Running` 으로 보일 수 있다.
스크립트는 root 로만 돌고, 컨트롤 플레인 노드(`/etc/kubernetes/manifests/kube-apiserver.yaml` 이 있는 노드)에서는 멈춘다. 노드 이름이 다른 랩이라면 `worker01` 자리에 자기 worker 노드 이름을 넣는다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

kubelet 설정 파일 `/var/lib/kubelet/config.yaml` 의 `clientCAFile` 경로를 `/etc/kubernetes/pki/ca.crt` 에서 없는 파일 `/etc/kubernetes/pki/ca.crtx` 로 바꾸고("동료의 수정") kubelet 을 재시작한다. kubelet 은 시작하자마자 종료되고 systemd 가 계속 다시 띄운다(`activating (auto-restart)`). containerd 는 건드리지 않는다.
고장 내기 전에 원본을 `/root/.cka-setup/a13-kubelet-config.yaml` 에 보관한다. `cleanup.sh` 는 원본으로 되돌리고 kubelet 을 enable 한 뒤 재시작한다. 문제를 다 풀었다면 이미 같은 내용이라 돌려도 해가 없다.

</details>

<details><summary>정리 명령 (방법 A, worker01 에서 root 로)</summary>

```bash
CFG=/var/lib/kubelet/config.yaml
KEEP=/root/.cka-setup

# 1) setup.sh 가 보관한 원본으로 되돌린다
if [ -f $KEEP/a13-kubelet-config.yaml ]; then
  cp -p $KEEP/a13-kubelet-config.yaml $CFG
  rm $KEEP/a13-kubelet-config.yaml
fi

# 2) kubelet 을 켜고 부팅 시 자동 시작도 켠 뒤 다시 띄운다
systemctl enable kubelet
systemctl restart kubelet

# 3) kubelet 이 계속 active 인지 확인 (최대 30초)
for _ in $(seq 10); do sleep 3; systemctl is-active --quiet kubelet && break; done
systemctl is-active kubelet
grep clientCAFile $CFG
```

</details>

## Task

Node `worker01` reports `NotReady` and its pods are stuck in `Terminating` or `Pending`.

1. From the control plane, identify which node condition is failing and what the kubelet
   last reported as the reason and message.
2. On `worker01`, report whether the kubelet unit is running and read its last 50 log lines.
3. Report the state of the container runtime on that node.
4. Identify the root cause and repair it so the node returns to `Ready`.
5. Confirm the node is `Ready` and that a new pod can be scheduled onto it.
6. Write down the order in which you narrowed the cause, one line per step.
7. Name one situation in which the kubelet is healthy and running but the node still
   reports `NotReady`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
