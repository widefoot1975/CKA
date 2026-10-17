# q15 — Fix a crash-looping Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q15_crashloop_wrong_command
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `jobs` 의 파드 `worker-...` 는 `Error` 또는 `CrashLoopBackOff` 이고 RESTARTS 가 1 이상이다. 그래서 `--previous` 로그가 이미 있다.

## Task

Deployment `worker` in namespace `jobs` (1 replica, image `busybox:1.36`) is in
`CrashLoopBackOff`. Its container `worker` is supposed to print a start message and then run
`sleep 3600`.

1. Write the logs of the **previous** (crashed) instance of container `worker` to
   `/opt/course/e15/previous.log`.
2. Write the exit code of that container's last termination to `/opt/course/e15/exitcode.txt`.
3. Fix the Deployment so that the container keeps running. Do not change the image.
4. Confirm that the new pod is `Running` and that its restart count does not increase any more.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_node_containerd_stopped/question.md) · [q16 →](../q16_coredns_scaled_to_zero/question.md)
