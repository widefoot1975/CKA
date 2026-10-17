# q14 — Node NotReady because the container runtime is down

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 8 min |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `worker02` 에서 root 로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q14_node_containerd_stopped
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
# k8s-c1 에서 (스크립트를 worker02 로 보내 root 로 실행)
ssh worker02 'sudo bash -s' < setup.sh      # 환경 만들기
ssh worker02 'sudo bash -s' < cleanup.sh    # 실습 후 정리

# 스크립트를 worker02 에 복사해 두었다면
sudo bash setup.sh
sudo bash cleanup.sh
```

설정 후 1분쯤 지나면 `worker02` 가 `NotReady` 가 된다. kubelet 은 계속 `active` 이고, 이미 떠 있던 컨테이너도 계속 돈다. `/opt/course/e14/` 는 비어 있다.
스크립트는 root 로만 돌고, 컨트롤 플레인 노드에서는 멈춘다. worker 가 하나뿐인 랩이라면 `worker02` 자리에 그 노드 이름을 넣는다. D13 을 같은 노드에서 연습했다면 D13 의 `cleanup.sh` 를 먼저 돌린다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

containerd 를 멈추고(`stop`) 부팅 시 자동 시작도 끈다(`disable`). containerd 유닛은 `KillMode=process` 라서 떠 있던 컨테이너는 죽지 않는다. `cleanup.sh` 는 containerd 를 `enable --now` 로 되돌리고, kubelet 이 멈춰 있으면 다시 띄운다.

</details>

## Task

Node `worker02` of cluster `k8s-c1` is `NotReady`. The kubelet service on `worker02` is running.

1. On `worker02`, use the kubelet journal to find out why the node is `NotReady`.
2. Fix the cause so that the fix also survives a reboot of `worker02`.
3. Write the name of the systemd service that caused the problem to `/opt/course/e14/cause.txt`
   on `worker02`.
4. Confirm that `worker02` becomes `Ready`.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_apiserver_wrong_etcd_endpoint/question.md) · [q15 →](../q15_crashloop_wrong_command/question.md)
