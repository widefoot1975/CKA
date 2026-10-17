# q02 — Upgrade the cluster lifecycle with kubeadm

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c2` → `ssh cp01` / `ssh worker01`, then `sudo -i` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 클러스터 전체를 한 마이너 올리므로 **한 번 풀면 되돌릴 수 없다.** kubeadm 은 컨트롤 플레인
다운그레이드를 지원하지 않아서, 스크립트로 "v1.34 클러스터"를 다시 만들어 줄 수도 없다. 그래서 setup 은
클러스터를 바꾸지 않고, 이 클러스터에서 한 마이너 올리기를 연습할 수 있는지만 점검한다. 문제의
v1.34 → v1.35 는 예시이고, 실제로는 "지금 버전 → 다음 마이너"로 읽는다.

**풀기 전에 모든 노드의 VM 스냅샷을 찍어 두기를 권한다.** 스냅샷으로 되돌리면 같은 업그레이드를 몇 번이고 다시
연습할 수 있다.

`cp01` 에서 root(`sudo -i`)로 아래 둘 중 하나를 실행한다. 아무것도 바꾸지 않으므로 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) cp01 에서 root 로
sudo -i
export KUBECONFIG=/etc/kubernetes/admin.conf

# 1) 지금 버전 — 노드별 kubelet 과 컨트롤 플레인
kubectl get nodes
kubectl get --raw /version | grep gitVersion          # 예: "v1.34.3" → 목표는 v1.35

# 2) 저장소가 지금 가리키는 마이너
grep -o 'core:/stable:/v[0-9.]*' /etc/apt/sources.list.d/kubernetes.list

# 3) 다음 마이너 저장소가 있는지 — 200 이 아니면 이미 최신이라 연습할 수 없다 (v1.35 자리에 다음 마이너)
curl -sL -o /dev/null -w '%{http_code}\n' https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release

# 4) 업그레이드 전 컨트롤 플레인 컴포넌트 상태
kubectl -n kube-system get pods -l tier=control-plane -o wide
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
sudo bash setup.sh      # cp01 에서 — 연습 가능 여부 점검 (OK / NG 로 알려 준다)
bash cleanup.sh         # k8s-c2 에서 — 중간에 그만뒀을 때 cordon 이 남은 노드 풀기
```

점검 결과가 OK 이면 그대로 풀면 된다. NG(다음 마이너 저장소가 없음) 이면 이 클러스터가 이미 최신 버전이라
연습할 수 없으니, 설치 가이드대로 클러스터를 한 마이너 낮은 저장소(`.../core:/stable:/v<한 마이너 낮은
버전>/deb/`)로 다시 만든다.
워커만 한 마이너 낮은 상태라면 먼저 [F03](../../mock_exam_f/q03_kubeadm_upgrade_worker/question.md) 으로 맞춘 뒤 푼다.
정리 스크립트는 업그레이드를 되돌리지 않는다. 중간에 그만둬서 `SchedulingDisabled` 로 남은 노드만 uncordon 한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl get nodes                       # SchedulingDisabled 로 남은 노드가 있으면
kubectl uncordon cp01 worker01
```

</details>

## Task

The cluster runs v1.34. Bring it to v1.35.

1. **Before** applying any upgrade, show the upgrade plan kubeadm proposes for v1.35.
2. Upgrade the control plane node `cp01`, including `kubelet` and `kubectl`.
3. Upgrade the worker node `worker01`.
4. Each node must be drained before its kubelet is replaced and made schedulable again
   afterwards.
5. Confirm every node reports v1.35 and is `Ready`, and that no control plane component
   is failing.

State in one line why the worker uses a different kubeadm subcommand than the control
plane.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
