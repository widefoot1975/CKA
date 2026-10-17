# q16 — Read and evaluate container output streams

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh <node running the pod>` for step 5 |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q16_container_log_streams
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `multi` 의 파드 3개는 모두 `READY 2/2`, `RESTARTS 1` 이다. `app` 의 첫 인스턴스는 stderr 에 FATAL 을 남기고 exit 1 로 죽었고,
지금 인스턴스는 30줄을 찍은 뒤 3초마다 INFO(stdout)/WARN(stderr) 를 남긴다. 줄마다 파드 이름이 들어 있어 어느 파드의 출력인지 구분된다.
`shipper` 는 지금은 **일반 컨테이너**(두 번째)이고, `app` 이 공유 볼륨에 쓴 줄을 `forwarded:` 를 붙여 다시 출력한다.
5단계는 `get pod -o wide` 의 NODE 열에 나온 노드로 `ssh` 해서 푼다.

namespace `logs` 는 `mock_exam_d/q16` 도 쓴다. 이 setup/cleanup 은 Deployment `multi` 만 다루고,
cleanup 은 namespace 에 다른 리소스가 남아 있으면 namespace 를 지우지 않는다.

## Task

Deployment `multi` in `logs` runs 3 replicas of containers `app` and `shipper`.

1. Print the output of `app` alone, then the output of both containers of one pod at once
   with each line tagged by container.
2. Print the last 20 lines of `app` with timestamps, then only the last 5 minutes of it.
3. Follow `app` live, and print the output of the previous instance of `app` after a restart.
4. Print the output for the whole Deployment, then for all three pods, and state in one line
   why those two are not the same.
5. On the node, locate the on-disk log file of one of these containers and read the same
   output with `crictl` instead of `kubectl`.
6. State in one line how `shipper` must be declared so that it starts before `app` and keeps
   running for the life of the pod.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_service_no_endpoints/question.md) · [q17 →](../q17_static_pod_manifest_error/question.md)
