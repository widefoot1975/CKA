# q11 — Create a default StorageClass

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q11_storageclass_default_wffc
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37 을 설치하고 StorageClass `local-path` 를 기본 클래스로 표시해 둔다. 설정 직후 `kubectl get sc` 에는 `local-path (default)` 가 있고 `local-fast` 는 없다.
클러스터에 원래 다른 기본 StorageClass 가 있었다면 `(default)` 가 두 개로 보일 수 있다. 그때는 문제 3번에서 둘 다 내린다. `cleanup.sh` 는 `local-fast` 를 지우고 `local-path` 를 다시 기본으로 돌려 둔다. 프로비저너는 D12 등 다른 Storage 문제에서도 쓰므로 남겨 둔다.

## Task

The local-path provisioner (`rancher.io/local-path`) is installed, and the cluster already has
a default StorageClass.

1. Create StorageClass `local-fast` with provisioner `rancher.io/local-path`, reclaimPolicy
   `Delete` and volumeBindingMode `WaitForFirstConsumer`.
2. Make `local-fast` the default StorageClass of the cluster.
3. Make the StorageClass that was the default before (check `kubectl get sc`) no longer the
   default, and confirm that exactly one StorageClass is marked `(default)`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_networkpolicy_allow_from_label/question.md) · [q12 →](../q12_pvc_pod_mount/question.md)
