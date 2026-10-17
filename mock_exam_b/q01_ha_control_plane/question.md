# q01 — Verify and operate a highly-available control plane

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c3` → `ssh cp01`, then `sudo -i` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **컨트롤 플레인 3대짜리 stacked HA 클러스터**(`cp01`, `cp02`, `cp03`, 로드밸런서 뒤)가 있어야 연습할
수 있다. setup 은 그 클러스터에서 "`cp03` 이 죽고 `kubeadm reset` 없이 새로 설치된" 상태를 만든다.
`kubeadm reset` 에서 **etcd 멤버를 지우는 단계만 건너뛰면**, `cp03` 머신은 깨끗해지고 클러스터에는 옛 etcd
멤버와 옛 Node 오브젝트가 그대로 남는다. 문제의 상태와 같다.

두 노드에서 차례로 root(`sudo -i`)로 실행한다. `cp03` 을 실제로 지우는 단계이므로 **VM 스냅샷을 먼저 찍어 두기를
권한다.** 정리 스크립트로 `cp03` 을 다시 join 시켜 3대로 되돌릴 수 있다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q01_ha_control_plane
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
sudo bash setup.sh prepare    # cp01 에서 — 점검, etcdctl 설치(없을 때), 답 디렉터리
sudo bash setup.sh fail       # cp03 에서 — yes 를 입력하면 cp03 을 지운다
sudo bash cleanup.sh          # cp01 에서 — 실습 후, cp03 을 다시 넣는 명령을 만들어 준다
```

설정 직후 `cp01` 에서 보면 etcd 멤버는 3개 등록되어 있지만 `cp03` 은 응답하지 않고(`endpoint health --cluster`
에서 false), Node `cp03` 은 `NotReady` 다. `/opt/q01` 은 비어 있다.
`cp03` 의 kubeadm·kubelet 패키지는 그대로 남으므로, 풀이에서 만든 `join.sh` 를 그 자리에서 바로 실행할 수 있다.
컨트롤 플레인이 3대보다 적으면 `setup.sh prepare` 가 멈춘다. 그런 실습 클러스터에서는 1)·3)·4) 의 명령만 따로
연습하고, 멤버 제거(2)는 하지 않는다. 멤버가 하나뿐인 etcd 에서 그 멤버를 지우면 클러스터가 멈춘다.

## Task

Cluster `k8s-c3` runs a stacked HA control plane on `cp01`, `cp02` and `cp03`. `cp03` died
and was rebuilt from scratch without running `kubeadm reset`, so its old etcd member is still
registered. The rebuilt `cp03` must come back.

1. From `cp01`, print the etcd member list and the health of every member with `etcdctl`,
   using the etcd server certificates. Write the number of registered members, how many are
   healthy, and how many **additional** member failures the cluster tolerates today to
   `/opt/q01/quorum.txt`.
2. Remove the stale `cp03` member from etcd, and the old `cp03` Node object if it still
   exists, so the rebuilt machine can join again.
3. On `cp01`, produce a join command that `cp03` can use to join **as a control plane
   node**, including a freshly uploaded certificate key. Write it to `/opt/q01/join.sh` —
   do not run it.
4. Write to `/opt/q01/upgrade.txt` which `kubeadm` subcommand upgrades `cp01` and which one
   upgrades `cp02` and `cp03`.
5. Confirm `cp01` and `cp02` are `Ready` and every remaining etcd member answers an
   endpoint health check.

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

[↑ 문항 목록](../README.md) · [q02 →](../q02_node_prerequisites_containerd/question.md)
