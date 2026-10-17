# q17 — Analyse resource usage per node and container

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q17_top_node_and_containers
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `monitoring` 에는 이 문제용 파드 두 개(`cka=e17` 레이블)가 `Running` 이다. metrics-server 가 첫 값을 모으기까지 1분 정도 걸릴 수 있다.
노드 CPU(1번)는 클러스터 상태 그대로 답한다. `monitoring` namespace 가 이미 있으면 그대로 쓰고, 정리할 때도 이 문제가 만든 파드만 지운다.

## Task

metrics-server is installed and working in cluster `k8s-c1`.

1. Write the name of the node that currently uses the most CPU to `/opt/course/e17/node.txt`.
2. Pod `analytics` in namespace `monitoring` has two containers, `collector` and `exporter`. Write
   the name of the container that currently uses more memory to `/opt/course/e17/container.txt`.
3. Write the name of the pod in namespace `monitoring` that currently uses the most memory to
   `/opt/course/e17/pod.txt`.

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

[↑ 문항 목록](../README.md) · [← q16](../q16_coredns_scaled_to_zero/question.md)
