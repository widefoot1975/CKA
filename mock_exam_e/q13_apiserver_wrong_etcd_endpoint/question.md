# q13 — API server down after a machine migration

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c2` → `ssh cp01`, then `sudo -i` |
| Target time | 9 min |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `cp01` 에서 root 로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q13_apiserver_wrong_etcd_endpoint
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
# k8s-c2 에서 (스크립트를 cp01 로 보내 root 로 실행)
ssh cp01 'sudo bash -s' < setup.sh      # 환경 만들기
ssh cp01 'sudo bash -s' < cleanup.sh    # 실습 후 정리

# 스크립트를 cp01 에 복사해 두었다면
sudo bash setup.sh
sudo bash cleanup.sh
```

**실행하면 이 클러스터의 `kubectl` 이 전부 멈춘다.** 문제를 풀거나 `cleanup.sh` 를 돌려야 돌아온다. 연습 랩에서는 `k8s-c2` 를 따로 만들 필요 없이 평소 쓰는 클러스터의 컨트롤 플레인 노드에서 하면 된다. 단일 노드가 아니어도 풀이는 같다.
설정 후 1~2분 뒤 `kubectl` 이 `connection refused` 로 실패하기 시작한다. `/opt/course/e13/` 는 비어 있다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

kube-apiserver 매니페스트의 `--etcd-servers` 를 옛 머신 주소 `https://10.0.5.20:2379` 로 바꾼다(노드 주소와 겹치면 `10.0.6.20`). 원래 값이 `https://127.0.0.1:2379` 가 아니면 스크립트가 원래 값을 출력하고, 그 경우 그 값으로 되돌리는 것이 정답이다.
고장 내기 전에 원본을 `/root/.cka-setup/kube-apiserver.yaml` 에 보관한다. `cleanup.sh` 는 그 원본으로 되돌리고, 매니페스트 디렉터리 안에 남은 `kube-apiserver` 백업 파일을 밖으로 옮긴 뒤 API 서버가 다시 응답할 때까지 기다린다. A17 도 같은 파일을 쓰지만, 두 setup 모두 먼저 원본으로 되돌린 뒤 고장 내므로 어느 순서로 해도 안전하다.

</details>

## Task

The single-node cluster `k8s-c2` was moved to a new machine, `cp01`. Since the move, every
`kubectl` command fails with `The connection to the server ... was refused`. etcd and the kubelet
on `cp01` are running normally.

1. On `cp01`, find out why kube-apiserver does not stay up. Use the container runtime and the
   static pod manifest; `kubectl` cannot help until the API server works.
2. Fix the kube-apiserver static pod manifest. Keep a backup copy of the original file outside
   `/etc/kubernetes/manifests`.
3. Write the wrong setting value you found to `/opt/course/e13/cause.txt`.
4. Confirm that `kubectl get nodes` works again and shows `cp01` as `Ready`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_emptydir_memory_sizelimit/question.md) · [q14 →](../q14_node_containerd_stopped/question.md)
