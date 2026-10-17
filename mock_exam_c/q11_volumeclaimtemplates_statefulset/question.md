# q11 — Per-replica storage with volumeClaimTemplates

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
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q11_volumeclaimtemplates_statefulset
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37 을 설치하고, StorageClass `standard` 가 없으면 local-path 를 쓰는 `standard`(WaitForFirstConsumer, reclaim Delete)를 만든다. 설정 직후 `kubectl get sc standard` 가 보이고 namespace `data` 에는 `queue` 관련 StatefulSet·Service·PVC 가 없다.
local-path 는 용량을 강제하지 않으므로 `df` 로 보이는 크기는 1Gi 가 아니라 노드 디스크 크기다. 또 볼륨 확장을 지원하지 않아 6번 뒤 PVC 를 직접 늘리는 연습은 이 환경에서는 안 된다(템플릿 변경이 거부되는 것은 그대로 확인할 수 있다).
namespace `data` 는 C10·D12 도 쓰므로 setup·cleanup 은 namespace 를 지우지 않고 `queue` StatefulSet·Service 와 `data-queue-*` PVC 만 지운다. `cleanup.sh` 는 setup 이 직접 만든 `standard` 만 지우고, 원래 있던 StorageClass 와 프로비저너는 남겨 둔다.

## Task

A StorageClass `standard` with dynamic provisioning already exists in the cluster.

1. In namespace `data`, create a StatefulSet `queue` with 3 replicas of `nginx:1.27`,
   governed by a headless Service `queue` you also create.
2. Each replica must get its own 1Gi `ReadWriteOnce` volume from StorageClass
   `standard`, mounted at `/var/lib/queue`, using a claim template named `data`.
3. List the PVCs that were created and record the exact naming pattern.
4. Write the file `/var/lib/queue/id` inside `queue-0` containing the text `zero`.
   Delete pod `queue-0` and prove that the file survived.
5. Scale the StatefulSet to 5, then back to 3. Record how many PVCs exist afterwards and
   explain the result.
6. Increase the claim template size to 2Gi and report what happens.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_headless_service_statefulset_dns/question.md) · [q12 →](../q12_pvc_expand_reclaim_behavior/question.md)
