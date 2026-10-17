# q13 — Node NotReady after a kubelet config change

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 9 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q13_kubelet_wrong_runtime_endpoint
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

`k8s-c1` 에서 실행하지만 실제 변경은 `ssh worker02` 로 노드에서 한다. 그래서 `k8s-c1` → `worker02` ssh 와 `worker02` 의 암호 없는 `sudo` 가 필요하다.
처음 실행할 때 `worker02` 의 `/var/lib/kubelet/config.yaml`(과 `kubeadm-flags.env`)을 `*.f13.orig` 로 보관하고, 다시 실행하면 그 원본에서 시작한다. 설정이 끝나면 `worker02` 가 `NotReady` 가 된다(최대 2분 기다린다).
실습이 끝나면 **반드시 `cleanup.sh`** 로 원본 설정을 되돌린다. 문제를 제대로 풀었어도 보관 파일 정리를 위해 실행한다.

## Task

Node `worker02` became `NotReady` shortly after someone edited the kubelet configuration
file `/var/lib/kubelet/config.yaml` on that node. containerd on `worker02` is running
normally.

1. On `worker02`, find out why the kubelet does not stay running. Write the wrong
   configuration value you found to `/opt/course/f13/cause.txt` on `worker02`.
2. Fix the configuration and restart the kubelet.
3. Confirm from `k8s-c1` that `worker02` is `Ready`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_projected_volume/question.md) · [q14 →](../q14_kubeconfig_wrong_port/question.md)
