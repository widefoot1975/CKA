# q17 — Find the heaviest Pod with kubectl top

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `batch` 는 C07 도 쓰므로 namespace 는 지우지 않고 이 문제의 파드만 정리한다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q17_top_pod_cpu
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `batch` 에는 `cruncher-1`(CPU 최대 100m), `cruncher-2`(CPU 최대 400m), `idle-0` 이 있다. metrics-server 가 첫 값을 모으기까지 1분 정도 걸릴 수 있다.
노드 메모리(2번)는 클러스터 상태 그대로 답한다.

## Task

metrics-server is running in the cluster. Several pods in namespace `batch` are busy.

1. Write the name of the pod in namespace `batch` that currently uses the most CPU to
   `/opt/course/d17/pod.txt` (the pod name only).
2. Write the name of the node that currently uses the most memory, in absolute terms (bytes,
   not percent), to `/opt/course/d17/node.txt` (the node name only).

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

[↑ 문항 목록](../README.md) · [← q16](../q16_sidecar_container_logs/question.md)
