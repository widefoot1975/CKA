# q04 — Inspect the container runtime with crictl

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` (kubectl will not answer) |
| Target time | 6 min |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `cp01` 에서 root 로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다. 실행하면 이 클러스터의 `kubectl` 이 전부 멈추므로, 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q04_crictl_container_runtime
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

설정 후 1분쯤 지나면 `kubectl` 은 `connection refused` 로 응답하지 않고, `kube-apiserver` 컨테이너가 재시작과 종료를 반복한다. `/etc/crictl.yaml` 은 없어서 `crictl` 이 엔드포인트 경고를 낸다. `/opt/q04/` 는 비어 있다.
6번(이미지 정리)은 이 노드에서 쓰지 않는 이미지를 실제로 지운다. 지워진 이미지는 나중에 필요할 때 레지스트리에서 다시 받으므로, 레지스트리에 접근할 수 없는 랩이라면 6번은 `crictl images` 로 목록만 보고 넘어간다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`kube-apiserver.yaml` 의 `--service-cluster-ip-range` 플래그 이름에 `s` 를 붙여(`--service-cluster-ip-ranges`) kube-apiserver 가 `unknown flag` 로 시작하자마자 종료하게 한다. 고장 내기 전에 원본을 `/root/.cka-setup/kube-apiserver.yaml` 에 보관한다. 원래 있던 `/etc/crictl.yaml` 은 `/root/.cka-setup/crictl.yaml` 로 옮겨 둔다(없었으면 표시 파일만 남긴다).
`cleanup.sh` 는 매니페스트를 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-apiserver` 백업 파일을 밖으로 옮기고, `/etc/crictl.yaml` 을 원래 상태로 돌려놓은 뒤 API 서버가 응답할 때까지 기다린다. A17·E13 도 같은 보관 파일을 쓰지만, 모든 setup 이 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

</details>

## Task

`kubectl` on `cp01` is unusable — the API server is not answering. Work at the runtime
level with `crictl`.

1. Write `/etc/crictl.yaml` so `crictl` needs no flags: runtime and image endpoint
   `unix:///run/containerd/containerd.sock`, timeout `10`, debug off.
2. List **all** pod sandboxes on the node, including those that are not ready, and write
   the count to `/opt/q04/sandboxes.txt`.
3. Find the `kube-apiserver` container, including exited ones. Write its container ID and
   state to `/opt/q04/apiserver.txt`.
4. Write the last 20 log lines of that container to `/opt/q04/apiserver.log`.
5. From `crictl inspect`, write the container's log path on the host to
   `/opt/q04/logpath.txt`.
6. List the images on the node and remove the ones no container references.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_crd_custom_resource/question.md) · [q05 →](../q05_hpa_workload_autoscaling/question.md)
