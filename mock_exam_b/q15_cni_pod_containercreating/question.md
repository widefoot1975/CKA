# q15 — Pods stuck in ContainerCreating after a CNI failure

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker01`, then `sudo -i` |
| Target time | 8 min |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `kubectl` 이 되고 `ssh worker01` 과 그 안의 `sudo` 가 되는 `k8s-c1` 에서 아래 스크립트를 실행한다. 노드 쪽 작업은 스크립트가 `ssh worker01 'sudo bash -s'` 로 보낸다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 클러스터를 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q15_cni_pod_containercreating
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
# k8s-c1 에서
bash setup.sh       # 환경 만들기
bash cleanup.sh     # 실습 후 정리

# worker 이름이 worker01 이 아니면
NODE=<worker 이름> bash setup.sh
NODE=<worker 이름> bash cleanup.sh
```

설정 후 `apps/web` 파드 4개 중 `worker01` 에 뜬 것(worker 2대면 2개)은 `ContainerCreating` 에 머물고 IP 가 없다. `worker02` 쪽은 `Running` 이고, `worker01` 은 계속 `Ready` 다. `worker01` 의 `/opt/q15/` 는 비어 있다.
Calico·flannel·Cilium 어느 CNI 든 동작하도록 `/etc/cni/net.d` 의 첫 설정 파일이 부르는 플러그인을 골라 고장 낸다. namespace `apps` 는 A05·D02 도 쓰므로, 그 문제들의 정리를 이 문제 전에 해 두면 깔끔하다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`worker01` 의 `/etc/cni/net.d` 에서 첫 설정 파일의 첫 `"type"`(예: `calico`, `flannel`, `cilium-cni`)을 읽어, 그 바이너리를 `/opt/cni/bin` 에서 `/root/.cka-setup/b15/bin/` 으로 옮긴다. 설정은 그대로라 노드는 `Ready` 로 남고, 새 sandbox 를 만들 때만 `failed to find plugin` 으로 실패한다. 그다음 `apps/web`(4 replica, worker 에 고르게 분산)을 만든다.
`cleanup.sh` 는 바이너리가 아직 없으면 보관본을 되돌리고(보관본도 없으면 그 노드의 CNI 파드를 재시작해 다시 설치하게 하고), `cka-setup=b15` 라벨이 붙은 `apps/web` 만 지운다. namespace `apps` 는 이 setup 이 만들었고 비었을 때만 지운다. 바이너리를 먼저 되돌리는 이유는, 플러그인이 없으면 파드를 지울 때 네트워크 정리(CNI DEL)가 실패해 파드가 `Terminating` 에 걸리기 때문이다.

</details>

## Task

Every pod scheduled to `worker01` is stuck in `ContainerCreating`. Pods on `worker02`
start normally. `worker01` reports `Ready`. Deployment `apps/web` has 4 replicas and only
the ones on `worker02` have an IP.

1. Write the pod event that explains the failure to `/opt/q15/event.txt`.
2. From `worker01`, check the runtime and the CNI state. Write the path of the CNI
   configuration directory and what you found there to `/opt/q15/cni.txt`.
3. Identify the cause and write it to `/opt/q15/cause.txt`.
4. Repair it so every `apps/web` pod reaches `Running` with a pod IP.
5. Clean up any sandbox left behind by the failed attempts.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_gateway_traffic_not_routed/question.md) · [q16 →](../q16_control_plane_component_down/question.md)
