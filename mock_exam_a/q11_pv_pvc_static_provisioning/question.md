# q11 — Static PersistentVolume provisioning

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` → `ssh worker01` for the node steps |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q11_pv_pvc_static_provisioning
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 디렉터리·PV·PVC·Pod 를 모두 직접 만드는 것부터 시작하므로, setup 은 이전 흔적을 지우고 `ops` 네임스페이스만 준비한다.
설정 직후 `pv-logs` 는 없고, `ops` 에 `pvc-logs`·`pvc-logs-2`·`logger` 가 없으며, worker01 에 `/mnt/data/logs` 도 없다.
`ops` 는 다른 문제(a12 등)도 쓰므로 setup·cleanup 모두 namespace 를 지우지 않고 이 문제의 리소스만 지운다.
Retain PV 는 PVC 를 지워도 남으므로 `cleanup.sh` 가 `pv-logs` 를 따로 지운다. worker01 의 `/mnt/data/logs` 는 남는다(다음 setup 이 지운다).

## Task

This cluster has no dynamic provisioner, so the volume must be prepared by hand.

1. On `worker01`, create the directory `/mnt/data/logs`.
2. Create a PersistentVolume `pv-logs`: 2Gi, `ReadWriteOnce`, `storageClassName: manual`,
   reclaim policy `Retain`, backed by `hostPath` `/mnt/data/logs`, and pinned to node
   `worker01` with node affinity so that every pod using it runs there.
3. In namespace `ops`, create a PersistentVolumeClaim `pvc-logs` requesting 1Gi
   `ReadWriteOnce` from storage class `manual`, and confirm it binds to `pv-logs`.
4. Create a Pod `logger` in `ops` running `busybox:1.36` with command
   `sh -c 'while true; do date >> /data/out.log; sleep 5; done'`, mounting the claim at
   `/data`. Show the file being written on the node.
5. Create a second claim `pvc-logs-2` in `ops` requesting 3Gi from `manual`, and state in
   one line why it stays `Pending`.

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

[↑ 문항 목록](../README.md) · [← q10](../q10_coredns_service_discovery/question.md) · [q12 →](../q12_access_modes_reclaim_policy/question.md)
