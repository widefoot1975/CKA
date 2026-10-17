# q11 — Reattach a retained volume to a new Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q11_retained_pv_reuse
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `ledger-pv` 는 `Available` 이고, 노드 한 곳(워커 우선)의 `/srv/ledger-pv/boot.log` 에 예전 데이터 `old ledger data` 가 들어 있다. PV 는 hostPath 라서 nodeAffinity 로 그 노드에 묶어 두었으므로 새 파드도 그 노드에 뜬다.
`/opt/course/e11/ledger-deploy.yaml` 은 `volumeMounts`·`volumes` 가 빠진 사본이다. PVC `ledger` 와 Deployment 는 문제에서 직접 만든다.
Retain PV 는 namespace 를 지워도 남으므로 `cleanup.sh` 가 `ledger-pv` 를 따로 지운다. 노드의 `/srv/ledger-pv` 디렉터리는 남는다(다음 setup 이 덮어쓴다).

## Task

Deployment `ledger` in namespace `finance` and its PVC were deleted by mistake. The data survived on
PersistentVolume `ledger-pv` (`250Mi`, `ReadWriteOnce`, storageClassName `manual`, reclaim policy
`Retain`), and an administrator has already made it `Available` again. A copy of the Deployment
manifest is at `/opt/course/e11/ledger-deploy.yaml`.

1. Create a PersistentVolumeClaim named `ledger` in namespace `finance` (`ReadWriteOnce`, `250Mi`,
   storageClassName `manual`) that binds to exactly `ledger-pv`.
2. Edit `/opt/course/e11/ledger-deploy.yaml` so that its container mounts PVC `ledger` at
   `/var/lib/ledger`, then apply the file.
3. Confirm that PVC `ledger` is `Bound` to `ledger-pv` and that the `ledger` pod is `Running`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_service_named_targetport/question.md) · [q12 →](../q12_emptydir_memory_sizelimit/question.md)
