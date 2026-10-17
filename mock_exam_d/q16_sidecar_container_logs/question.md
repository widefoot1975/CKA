# q16 — Read logs from an app and its sidecar

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `logs` 는 A16 도 쓰므로 namespace 는 지우지 않고 이 문제의 파드만 정리한다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q16_sidecar_container_logs
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `order-api` 는 `READY 2/2`, `RESTARTS 1` 이다. `api` 의 첫 인스턴스는 FATAL 을 남기고 exit 1 로 죽었고, 두 컨테이너 모두 5초마다 INFO/ERROR 줄을 남긴다.
네이티브 사이드카를 쓰므로 v1.29 이상 클러스터가 필요하다.

## Task

Namespace `logs` contains pod `order-api` with an app container `api` and a native sidecar
container `log-agent` (declared under `initContainers` with `restartPolicy: Always`).

1. Write the last 10 lines of the `log-agent` container's log to `/opt/course/d16/agent.log`.
2. Container `api` has restarted once. Write the log of its previous instance to
   `/opt/course/d16/api-previous.log`.
3. Write every log line from the last 30 minutes, from all containers of the pod, that contains
   `ERROR` to `/opt/course/d16/errors.log`. Each line must be prefixed with the name of the
   container it came from.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_service_selector_mismatch/question.md) · [q17 →](../q17_top_pod_cpu/question.md)
