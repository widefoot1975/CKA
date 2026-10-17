# q11 — Protect a dynamically provisioned volume

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q11_pv_reclaim_policy_patch
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37(D11·D12 와 같은 설치)을 쓰고, `db` 에 PVC `pg-data`(1Gi)와 그것을 마운트한 파드 `pg` 를 만든다. StorageClass 가 `WaitForFirstConsumer` 라서 파드가 떠야 PV 가 만들어지고 `Bound` 된다.
`Retain` 으로 바꾼 PV 는 PVC 를 지워도 남으므로, `setup.sh`·`cleanup.sh` 는 `db` 를 지우기 전에 PV 를 `Delete` 로 되돌린 뒤 정리한다. 프로비저너는 남겨 둔다.

## Task

In namespace `db`, PVC `pg-data` is `Bound` to a PersistentVolume that was dynamically
provisioned by a StorageClass with reclaim policy `Delete`. The data on that volume must
survive even if the PVC is deleted by mistake.

1. Write the name of the PersistentVolume bound to PVC `pg-data` to
   `/opt/course/f11/pv.txt`.
2. Change the reclaim policy of that PersistentVolume to `Retain`, without recreating the
   PV, the PVC or the StorageClass.
3. Verify that `kubectl get pv` shows `Retain` for that volume and that `pg-data` is still
   `Bound`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_coredns_hosts_entry/question.md) · [q12 →](../q12_projected_volume/question.md)
