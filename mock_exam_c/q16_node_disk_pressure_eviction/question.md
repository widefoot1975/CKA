# q16 — Pods evicted under node disk pressure

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 8 min |

## Setup — 사전 환경 설정

이 문제는 **노드 디스크를 일부러 채운 상태에서** 시작한다. `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 공간과 설정을 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q16_node_disk_pressure_eviction
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

`k8s-c1` 에서 실행하지만 실제 변경은 `ssh worker02` 로 노드에서 한다. 그래서 `k8s-c1` → `worker02` ssh 와 `worker02` 의 암호 없는 `sudo` 가 필요하다. 이미지 `busybox:1.36` 을 받을 수 있어야 하고, `worker02` 의 `/var/lib/kubelet` 파일시스템에 1GiB 이상 남아 있어야 한다.
설정이 끝나면(최대 3분 기다린다) `worker02` 는 `Ready` 그대로지만 `DiskPressure=True` 이고, namespace `diskload` 의 파드 일부가 `Evicted`, 새로 생긴 파드는 `Pending` 이다. **`worker02` 에 떠 있던 다른 실습의 일반 파드도 함께 축출될 수 있다.**
`worker02` 에서 채운 크기는 남은 공간의 40%(최대 2GiB)라 디스크가 꽉 차지는 않는다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`worker02` 의 `/var/lib/kubelet/config.yaml` 을 처음 실행할 때 `config.yaml.c16.orig` 로 보관한다. 그다음 `/var/lib/c16-dump/core.img` 로 디스크를 채우고, `evictionHard` 의 `nodefs.available` 을 "채운 뒤 남은 공간보다 크고, 그 파일을 지우면 남는 공간보다 작은" 값(MiB)으로 정해 kubelet 을 재시작한다. 그래서 큰 파일을 찾아 지우면 컨디션이 풀린다.
`cleanup.sh` 는 그 파일을 지워 공간을 돌려주고, 보관한 원본 설정으로 되돌린 뒤 kubelet 을 재시작하고 namespace `diskload` 를 지운다. 문제를 제대로 풀었어도 임계값과 보관 파일을 되돌리려면 꼭 실행한다.

</details>

## Task

Pods on `worker02` are disappearing. Several show status `Evicted`, and new pods stay
`Pending` with no node chosen. Other nodes are unaffected.

1. Show the node condition that explains this and the message the kubelet attached to it.
2. Report the kubelet eviction thresholds in effect on `worker02` and which filesystem
   signal crossed its threshold.
3. Find what is consuming the disk, distinguishing container images from container logs
   from other data.
4. Reclaim space so the condition clears. Remove unused images through the container
   runtime, not by deleting files under `/var/lib/containerd` by hand.
5. Confirm the node accepts pods again, and clean up the `Evicted` pod objects.
6. Note the difference between an evicted pod and an OOMKilled container in one line.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_multicontainer_sidecar_logs/question.md) · [q17 →](../q17_kubeproxy_service_networking/question.md)
