# q12 — Expand a PVC and observe reclaim behaviour

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q12_pvc_expand_reclaim_behavior
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37(B11·F11 과 같은 설치)을 쓴다. 설정 직후 StorageClass `slow`(`rancher.io/local-path`, `Delete`, `WaitForFirstConsumer`)는 `ALLOWVOLUMEEXPANSION` 이 `false`(필드 없음)이고, `files` 에는 1Gi `Bound` PVC `archive` 와 그것을 `/data` 에 마운트한 `writer` 가 `Running` 이다.
**이 환경에서는 2번의 확장이 끝나지 않는다.** local-path 는 볼륨 확장을 지원하지 않아서, `allowVolumeExpansion` 을 켠 뒤 PVC 를 `3Gi` 로 패치하면 API 서버는 받아 주지만 실제로 늘려 줄 컨트롤러가 없다. `spec` 은 `3Gi`, `status.capacity` 는 `1Gi` 에 머물고 `df` 는 볼륨이 아니라 노드 디스크 크기를 보여 준다. 1번, 2번의 패치, 3번(축소 거부), 4·5번(Retain·Released·Available)은 그대로 연습할 수 있고, 끝까지 늘어나는 것을 보려면 확장을 지원하는 CSI 드라이버(Longhorn, TopoLVM 등)가 필요하다.
`Retain` PV 는 PVC 를 지워도 남으므로 `setup.sh`·`cleanup.sh` 는 `slow-retain` PV 를 `Delete` 로 되돌린 뒤 정리한다. 5번에서 `Available` 로 돌린 PV 는 프로비저너가 지우지 않으므로 노드의 `/opt/local-path-provisioner/pvc-…_files_scratch` 디렉터리가 남을 수 있다. A12 는 `slow` 라는 StorageClass 가 없다는 전제로 풀리므로, A12 를 풀기 전에 이 문제의 `cleanup.sh` 를 꼭 실행한다. 프로비저너는 남겨 둔다.

## Task

Namespace `files` has a PVC `archive` of 1Gi, `Bound`, using StorageClass `slow`, and a
pod `writer` mounting it at `/data`. The CSI driver behind `slow` supports online
expansion.

1. Check whether `slow` allows volume expansion. `archive` must be expanded where it is,
   so if expansion is not allowed, change what is needed — a bound PVC cannot move to
   another class.
2. Expand `archive` from 1Gi to 3Gi and confirm the filesystem inside `writer` sees the
   new size, without restarting `writer`.
3. Attempt to shrink `archive` back to 1Gi and record the exact error.
4. Create StorageClass `slow-retain`, identical to `slow` except reclaim policy `Retain`.
   Create a PVC `scratch` (500Mi) from it and make sure it actually gets a PV, then delete
   the claim and report the state of that PV and why it is in that state.
5. Make that PV available for a new claim again without deleting it.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_volumeclaimtemplates_statefulset/question.md) · [q13 →](../q13_coredns_resolution_failure/question.md)
