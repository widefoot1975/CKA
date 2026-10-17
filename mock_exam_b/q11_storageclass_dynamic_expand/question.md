# q11 — Dynamic provisioning and volume expansion

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q11_storageclass_dynamic_expand
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

local-path 프로비저너 v0.0.37 을 설치하고 StorageClass `local-path` 를 확장을 허용하지 않는 기본 클래스로 만들어 둔다. 설정 직후 `kubectl get sc` 에는 `local-path (default)` 가 `ALLOWVOLUMEEXPANSION false` 로 보이고 `fast-expand` 는 없다. namespace `store` 와 답 디렉터리 `/opt/q11` 도 만들어 둔다.
**이 환경에서는 4번이 끝나지 않는다.** local-path 는 볼륨 확장을 지원하지 않아서 PVC 를 `3Gi` 로 패치하면 API 서버는 받아 주지만 실제로 늘려 줄 컨트롤러가 없다. `spec` 은 `3Gi`, `status.capacity` 는 `1Gi` 에 머물고 `df` 는 볼륨이 아니라 노드 디스크 크기를 보여 준다. 1~3번과 5번, 그리고 4번의 패치까지 연습하고, 끝까지 늘어나는 것을 보려면 확장을 지원하는 CSI 드라이버(Longhorn, TopoLVM 등)가 있는 클러스터가 필요하다.
클러스터에 원래 다른 기본 StorageClass 가 있었다면 `(default)` 가 두 개로 보일 수 있다. 그때는 문제 2번에서 둘 다 내린다. `cleanup.sh` 는 `writer`·`data-pvc`·`fast-expand`·`/opt/q11` 을 지우고 `local-path` 를 다시 기본으로 돌려 둔다. 프로비저너는 다른 Storage 문제에서도 쓰고 namespace `store` 는 D15 도 쓰므로 남겨 둔다.

## Task

The cluster has one StorageClass, which is the default and does not allow expansion. Its
CSI driver supports online volume expansion.

1. Create a StorageClass named `fast-expand` reusing the **same provisioner** as the
   existing default class, with `allowVolumeExpansion: true`,
   `volumeBindingMode: WaitForFirstConsumer` and `reclaimPolicy: Delete`.
2. Make `fast-expand` the cluster default and make sure the previous default class is no
   longer marked as default.
3. In namespace `store`, create PVC `data-pvc` requesting `1Gi`, access mode
   `ReadWriteOnce`, from `fast-expand`. Create pod `writer` (`nginx:1.27`) mounting it at
   `/data`.
4. Expand `data-pvc` to `3Gi` and confirm both the PVC `status.capacity` and the
   filesystem inside `writer` report the new size.
5. Write to `/opt/q11/pending.txt` the PVC condition you would see if the driver could
   only expand offline, and what you would do about it.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_pod_connectivity_check/question.md) · [q12 →](../q12_csi_driver_volumemode/question.md)
