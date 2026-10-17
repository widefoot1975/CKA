# q03 — Upgrade one worker node with kubeadm

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c2` → `ssh worker01`, then `sudo -i` |
| Target time | 6 min |

## Setup — 사전 환경 설정

이 문제는 "컨트롤 플레인은 새 버전, `worker01` 만 한 마이너 낮은 버전"인 상태에서 시작한다. 실습
클러스터는 보통 모든 노드가 같은 버전이므로, `worker01` 의 `kubeadm`·`kubelet`·`kubectl` 을 한 마이너
**내려서** 그 상태를 만든다. 문제의 v1.35/v1.34 는 예시이고, 스크립트는 지금 컨트롤 플레인 버전을 읽어서
그보다 한 마이너 낮은 버전으로 맞춘다.
`worker01` 에서 root(`sudo -i`)로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q03_kubeadm_upgrade_worker
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q02](../q02_clusterrole_rolebinding_scope/question.md) · [q04 →](../q04_extension_interfaces_inventory/question.md)
