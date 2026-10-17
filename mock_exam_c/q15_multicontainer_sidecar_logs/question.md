# q15 — Read output streams from a multi-container pod

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q15_multicontainer_sidecar_logs
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `tracker` 는 `READY 2/2`, `RESTARTS 1` 이다. `setup` 은 세 줄을 찍고 끝났고, `app` 과 `shipper` 는 INFO 사이사이 ERROR 를 남긴다.
5번의 네이티브 사이드카를 쓰므로 v1.29 이상 클러스터가 필요하다. namespace `obs` 는 mock_exam_f/q16 과 같이 쓰므로 정리할 때 이 문제의 파드만 지운다.

## Task

Namespace `obs` contains pod `tracker` with containers `app`, `shipper` and an init
container `setup`. A colleague ran `kubectl logs tracker`, got output without any error,
and concluded that `shipper` is healthy.

1. Report which container the plain `kubectl logs tracker` actually printed and why, and
   list the pod's containers (including the init container) without reading the whole
   manifest. Then make `shipper` the container a plain `kubectl logs tracker` shows,
   without recreating the pod.
2. Write the last 20 lines of the `app` container's log to
   `/opt/course/q15/app.log`.
3. The `shipper` container restarted once. Write the log of its **previous** instance to
   `/opt/course/q15/shipper-prev.log` and state the restart reason.
4. Write every line produced by any container in the last 10 minutes containing the
   string `ERROR` to `/opt/course/q15/errors.log`.
5. Create a new pod `tailer` in `obs` that runs `nginx:1.27` writing access logs to
   `/var/log/nginx/access.log` on a shared `emptyDir`, plus a native sidecar named
   `logship` (`busybox:1.36`) that tails that file to its own stdout. Prove that
   `kubectl logs tailer -c logship` shows nginx requests.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_oomkilled_resource_analysis/question.md) · [q16 →](../q16_node_disk_pressure_eviction/question.md)
