# q07 — Add a native sidecar to an existing Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q07_native_sidecar_log_shipper
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 파드는 `1/1` 이고 `initContainers` 는 비어 있다.

## Task

Deployment `synergy-app` in namespace `synergy` has a single container `app` (`busybox:1.36`)
that appends a line to `/var/log/app.log` every few seconds. The file lives on the `emptyDir`
volume `logs`, which is mounted at `/var/log`.

1. Add a sidecar container named `sidecar` to the Deployment: image `busybox:1.36`, command
   `sh -c 'tail -n+1 -F /var/log/app.log'`, mounting volume `logs` at `/var/log`.
2. Define it as a **native sidecar**: an init container that keeps running for the whole life of
   the pod. Do not change container `app`.
3. Confirm that the new pod shows `2/2` ready and that the logs of container `sidecar` show the
   lines written by `app`.

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

[↑ 문항 목록](../README.md) · [← q06](../q06_resource_requests_all_containers/question.md) · [q08 →](../q08_httproute_path_routing/question.md)
