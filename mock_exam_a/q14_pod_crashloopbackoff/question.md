# q14 — Diagnose a CrashLoopBackOff pod

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

이 문제는 **일부러 고장 낸 파드**에서 시작한다. `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q14_pod_crashloopbackoff
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `dev` 의 파드 `broken-app` 은 `OOMKilled` 또는 `CrashLoopBackOff` 이고 RESTARTS 가 1 이상이다. 그래서 `lastState` 와 `--previous` 로그가 이미 있다.
namespace `dev` 는 A04(jane 의 Role/RoleBinding) 도 쓰므로 setup 과 cleanup 은 namespace 를 지우지 않고 `broken-app` 파드만 다시 만들거나 지운다.

## Task

Pod `broken-app` in namespace `dev` is in `CrashLoopBackOff`.

1. Report its restart count, the last exit code and the termination reason of the failing
   container.
2. Read the output of the instance that crashed, not of the one currently starting.
3. From the exit code, name the most likely cause before changing anything.
4. Repair the pod so it stays `Running`.
5. For exit codes 0, 1, 127 and 137 write the usual cause, one line each.
6. State in one line how you distinguish `CrashLoopBackOff` from `ImagePullBackOff` without
   reading any logs.

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

[↑ 문항 목록](../README.md) · [← q13](../q13_node_notready_kubelet/question.md) · [q15 →](../q15_service_no_endpoints/question.md)
