# q01 — Install and upgrade a Helm release

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q01_helm_install_pinned_chart
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `podinfo` 차트 저장소, namespace `demo`, 릴리스 `podinfo` 는 모두 없고 `/opt/course/d01/` 는 비어 있다. 저장소 추가부터 문제에서 직접 한다.
차트를 받아야 하므로 `k8s-c1` 에서 `stefanprodan.github.io` 와 `ghcr.io` 로 인터넷 연결이 되어야 한다.

## Task

The team wants the `podinfo` demo application installed with Helm. The chart version must be
pinned so that every later change uses exactly the same chart.

1. Add the chart repository `podinfo` at `https://stefanprodan.github.io/podinfo`, refresh the
   repository index, and write the latest version of chart `podinfo/podinfo` shown by
   `helm search repo` to `/opt/course/d01/version.txt`.
2. Install release `podinfo` from chart `podinfo/podinfo` into namespace `demo` (create the
   namespace), passing exactly that version with `--version` and setting `replicaCount=2`.
3. Upgrade the release, with the same chart version, to set `ui.message=hello-cka` without
   losing the `replicaCount` set in step 2.
4. Confirm that the release history shows 2 revisions and that the release's Deployment runs
   2 ready pods.

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

[↑ 문항 목록](../README.md) · [q02 →](../q02_rbac_pod_reader_serviceaccount/question.md)
