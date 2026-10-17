# q12 — Claim storage and mount it in a Pod

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
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q12_pvc_pod_mount
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37(D11 과 같은 설치)과 빈 namespace `data` 를 만든다. PVC 와 파드는 문제에서 직접 만든다.
StorageClass `local-path` 의 reclaimPolicy 는 `Delete` 라서 `cleanup.sh` 가 `data` 를 지우면 PV 와 노드의 데이터 디렉터리도 함께 지워진다. 프로비저너는 남겨 둔다.

## Task

Namespace `data` exists. StorageClass `local-path` (provisioner `rancher.io/local-path`,
volumeBindingMode `WaitForFirstConsumer`) is available.

1. Create a PersistentVolumeClaim `app-data` in `data` that requests `1Gi` with access mode
   `ReadWriteOnce` from StorageClass `local-path`. Confirm that it is `Pending` while no pod
   uses it.
2. Create pod `writer` in `data` (image `busybox:1.36`) that mounts the claim at `/data` and
   runs `sh -c 'date > /data/out.txt; sleep 3600'`.
3. Confirm that the claim is now `Bound` and that `/data/out.txt` in the pod contains the date.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_storageclass_default_wffc/question.md) · [q13 →](../q13_node_kubelet_stopped/question.md)
