# q16 — Collect logs from every container of a Pod

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `obs` 는 C15 도 쓰므로 namespace 는 지우지 않고 이 문제의 파드만 정리한다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q16_multicontainer_logs_prefix
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `pipeline` 은 `READY 2/2` 다. `migrate` 는 세 줄을 찍고 끝났고, `ingest` 는 INFO 만, `transform` 은 세 줄에 한 번 ERROR 를 남긴다.

## Task

In namespace `obs`, Pod `pipeline` has one init container `migrate` and two containers
`ingest` and `transform`. The Pod is `Running`.

1. Write the names of all containers of Pod `pipeline` to `/opt/course/f16/containers.txt`,
   one per line: init containers first, then the regular containers, each in spec order.
2. Write the logs of all containers of `pipeline`, including the init container, to
   `/opt/course/f16/all.log`, with every line prefixed by the container it came from.
3. Write only the lines containing `ERROR` that container `transform` logged in the last
   15 minutes, with timestamps, to `/opt/course/f16/transform-errors.log`.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_service_targetport_mismatch/question.md) · [q17 →](../q17_resize_pod_in_place/question.md)
