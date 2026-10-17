# q14 — Pods stay Pending because the scheduler is broken

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` |
| Target time | 8 min |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `cp01` 에서 root 로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q14_scheduler_static_pod_image
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
# k8s-c1 에서 (스크립트를 cp01 로 보내 root 로 실행)
ssh cp01 'sudo bash -s' < setup.sh      # 환경 만들기
ssh cp01 'sudo bash -s' < cleanup.sh    # 실습 후 정리

# 스크립트를 cp01 에 복사해 두었다면
sudo bash setup.sh
sudo bash cleanup.sh
```

설정 후 30초~1분 뒤 `kube-scheduler-<노드이름>` 이 `ErrImagePull` / `ImagePullBackOff` 가 된다. 랩의 컨트롤 플레인 노드 이름이 `cp01` 이 아니면 파드 이름도 그 이름을 따른다. `/opt/course/d14/` 는 비어 있다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

kube-scheduler 이미지 태그 끝에 `x` 를 붙인다(예: `v1.35.0x`). 고장 내기 전에 원본을 `/root/.cka-setup/kube-scheduler.yaml` 에 보관하며, 풀이에서 만드는 `/opt/course/d14/kube-scheduler.yaml.bak` 과는 별개다. 원본의 태그가 kube-apiserver 와 다르면 원본이 아니라고 보고 멈춘다.
`cleanup.sh` 는 보관한 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-scheduler` 백업 파일(`.bak` 등)을 `/root/.cka-setup/` 로 옮기고, `sched-test` 파드를 지운 뒤 스케줄러가 다시 뜰 때까지 기다린다. B16 도 같은 파일을 쓰지만, 두 setup 모두 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

</details>

## Task

Newly created pods stay `Pending` and show no events. `kubectl -n kube-system get pods` shows
`kube-scheduler-cp01` in `ImagePullBackOff`.

1. On `cp01`, find what is wrong in the kube-scheduler static pod manifest.
2. Before changing it, copy the manifest to `/opt/course/d14/kube-scheduler.yaml.bak` on `cp01`.
3. Fix the manifest so that kube-scheduler uses the same image tag as the kube-apiserver
   manifest.
4. Confirm that `kube-scheduler-cp01` is `Running` and that a new pod `sched-test`
   (image `nginx:1.27`, namespace `default`) gets scheduled to a node.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_node_kubelet_stopped/question.md) · [q15 →](../q15_service_selector_mismatch/question.md)
