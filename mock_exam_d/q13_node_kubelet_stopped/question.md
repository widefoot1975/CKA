# q13 — Bring a NotReady node back

| Item | Value |
|---|---|
| Exam | mock_exam_d |
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
# 1) 이전 실습 흔적 정리
rm -rf /opt/course/d13
mkdir -p /opt/course/d13

# 2) 고장 내기: kubelet 을 멈추고(stop) 부팅 때 자동 시작도 끈다(disable)
systemctl disable --now kubelet

# 3) 시작 상태 확인: inactive / disabled. 약 1분 뒤 k8s-c1 에서 worker01 이 NotReady 로 바뀐다
systemctl is-active kubelet || true
systemctl is-enabled kubelet || true
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

설정 후 40초~1분쯤 지나면 `k8s-c1` 에서 `kubectl get nodes` 로 `worker01` 이 `NotReady` 로 보인다. 그때부터 푼다. `/opt/course/d13/` 는 비어 있다.
스크립트는 root 로만 돌고, 컨트롤 플레인 노드(`/etc/kubernetes/manifests/kube-apiserver.yaml` 이 있는 노드)에서는 멈춘다. 노드 이름이 다른 랩이라면 `worker01` 자리에 자기 worker 노드 이름을 넣는다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

kubelet 을 멈추고(`stop`) 부팅 시 자동 시작도 끈다(`disable`). `cleanup.sh` 는 `systemctl enable --now kubelet` 으로 되돌린다. 문제를 다 풀었다면 이미 같은 상태라 돌려도 해가 없다.

</details>

<details><summary>정리 명령 (방법 A, worker01 에서 root 로)</summary>

```bash
systemctl enable --now kubelet
rm -rf /opt/course/d13
systemctl is-active kubelet
systemctl is-enabled kubelet
```

</details>

## Task

Node `worker01` reports `NotReady`. The cause is on the node itself.

1. From `k8s-c1`, find which condition of `worker01` is failing and the message reported for it.
2. On `worker01`, find the cause and fix it so that the node also comes back `Ready` after a
   reboot.
3. Write the cause in one line to `/opt/course/d13/cause.txt` on `worker01`.
4. Confirm that `worker01` is `Ready`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
