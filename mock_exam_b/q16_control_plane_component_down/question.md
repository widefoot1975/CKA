# q16 — A control plane component is not running

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` |
| Target time | 8 min |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `cp01` 에서 root 로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q16_control_plane_component_down
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

설정 후 1분 안에 `kube-scheduler-<노드이름>` 이 `kubectl -n kube-system get pods` 목록에서 사라지고, 새 파드는 이벤트 없이 `Pending` 에 머문다. 기존 파드와 `kubectl` 은 그대로 동작한다. `/opt/q16/` 는 비어 있다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`kube-scheduler.yaml` 의 `image:` 줄 들여쓰기를 4칸에서 3칸으로 바꿔 yaml 파싱을 깨뜨린다. kubelet 은 이 디렉터리를 20초쯤마다 다시 읽으며, 읽지 못한 파일의 정적 파드는 내린다.
고장 내기 전에 원본을 `/root/.cka-setup/kube-scheduler.yaml` 에 보관한다. `cleanup.sh` 는 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-scheduler` 백업 파일을 밖으로 옮기고, `sched-test` 파드를 지운 뒤 스케줄러가 다시 뜰 때까지 기다린다. D14 도 같은 파일을 쓰지만, 두 setup 모두 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

</details>

## Task

Newly created pods stay `Pending` forever with no scheduling events. Existing pods keep
running and `kubectl` works normally.

1. Identify which control plane component is failing and write its name to
   `/opt/q16/component.txt`.
2. On `cp01`, find the reason using the container runtime and the kubelet journal, since
   the component's pod does not appear in `kubectl get pods -n kube-system`. Write the
   decisive log line to `/opt/q16/log.txt`.
3. Repair the component. Do not delete anything under `/etc/kubernetes/pki`.
4. Confirm a new pod schedules and the component is `Running` and `1/1`.
5. Write to `/opt/q16/why.txt` where this component's manifest lives and why
   `kubectl delete pod` is not how you restart it.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_cni_pod_containercreating/question.md) · [q17 →](../q17_kubelet_certificate_expired/question.md)
