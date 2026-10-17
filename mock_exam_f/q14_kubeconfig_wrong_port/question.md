# q14 — kubectl cannot reach the API server

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q14_kubeconfig_wrong_port
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

처음 실행할 때 `~/.kube/config` 를 `~/.kube/config.f14.orig` 로 보관하고, 다시 실행하면 그 원본에서 시작한다. 설정이 끝나면 `k8s-c1` 의 `kubectl` 이 전부 실패한다.
오류 메시지의 주소는 지금 kubeconfig 의 server 주소를 따른다. 실습 클러스터의 server 가 `cp01` 이 아니라 IP 라면 `cp01:6444` 대신 그 IP 가 보이고, 1번의 `curl` 도 그 주소로 하면 된다.
**다른 문제의 setup 을 먼저 모두 실행하고 이것을 마지막에 실행한다.** 이 문제를 풀기 전에는 다른 문제도 kubectl 을 쓸 수 없다. 실습이 끝나면 `cleanup.sh` 로 원본을 되돌린다.

## Task

On `k8s-c1`, every `kubectl` command fails, for example:

```
$ kubectl get nodes
The connection to the server cp01:6444 was refused - did you specify the right host or port?
```

The API server itself is running normally on `cp01`, port `6443`. `kubectl` on `k8s-c1`
uses the kubeconfig file `~/.kube/config`.

1. Without using `kubectl`, show that the API server answers on `https://cp01:6443/livez`.
2. Write the wrong server URL that is currently configured in `~/.kube/config` to
   `/opt/course/f14/cause.txt`.
3. Fix `~/.kube/config` so that `kubectl get nodes` works again.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_kubelet_wrong_runtime_endpoint/question.md) · [q15 →](../q15_service_targetport_mismatch/question.md)
