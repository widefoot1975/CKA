# q12 — Inspect CSI drivers and use a block volumeMode

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

이 문제는 Block 모드를 지원하는 스토리지가 있어야 3~5번을 풀 수 있다. 실습 클러스터에는 보통 그런 CSI 드라이버가
없으므로, `worker01` 에 2Gi 짜리 loop 블록 디바이스를 만들고 그것을 가리키는 Block 모드 PV 와 StorageClass
`csi-block` 을 미리 만들어 둔다. CSI 드라이버가 하나도 등록되어 있지 않으면 1번 답이 빈 파일이 되지 않도록 연습용
CSIDriver 등록 오브젝트도 하나 만든다.
`k8s-c1` 에서 아래 스크립트로 환경을 만든다(`k8s-c1` 에서 `ssh worker01` 이 되어야 한다). 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q12_csi_driver_volumemode
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/q12` 는 비어 있고, `kubectl get csidrivers` 에 드라이버가 한 개 이상 보이며, `raw` 에는 PVC 도
파드도 없다. 연습용 StorageClass 를 만든 경우 PV `b12-block-pv`(2Gi, `Block`, `Available`)가 하나 있다.
StorageClass 가 `WaitForFirstConsumer` 라서 PVC 를 만들어도 파드가 생길 때까지 `Pending` 인 것이 정상이고,
파드는 PV 의 nodeAffinity 때문에 `worker01` 에 뜬다. 스크립트는 이미 드라이버나 `csi-block` 이 있으면 새로 만들지
않고 있는 것을 쓴다.
연습용 `hostpath.csi.k8s.io` 는 **등록 정보(CSIDriver 오브젝트)만** 있고 드라이버 파드가 없으므로 `csinodes` 의
`drivers` 는 비어 있다. 그때 2번 답은 노드 이름과 빈 node ID(`<none>`)가 된다. 연습용 `csi-block` 은 CSI 가 아니라
`local` PV 로 Block 디바이스를 흉내 낸 것이지만, PVC·파드 쪽 작성법(3~5번)은 CSI 드라이버를 쓸 때와 똑같다.
loop 디바이스는 `worker01` 을 재부팅하면 풀리므로 재부팅 뒤에는 setup 을 다시 실행한다.

## Task

A database is being migrated to raw block storage.

1. List the CSI drivers registered in the cluster. For each, write its name and whether
   it requires attach (`spec.attachRequired`) to `/opt/q12/drivers.txt`.
2. Write to `/opt/q12/csinodes.txt` each node's name together with the driver-specific
   node ID the CSI driver registered for it.
3. In namespace `raw`, create PVC `block-pvc`: `2Gi`, `ReadWriteOnce`, StorageClass
   `csi-block`, `volumeMode: Block`.
4. Create pod `block-user` (`busybox:1.36`, kept alive) that consumes `block-pvc` as a
   raw device at `/dev/xvdb`. Do **not** mount a filesystem.
5. From inside the pod, prove `/dev/xvdb` is a block device and write the proof to
   `/opt/q12/proof.txt`.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_storageclass_dynamic_expand/question.md) · [q13 →](../q13_metrics_server_resource_usage/question.md)
