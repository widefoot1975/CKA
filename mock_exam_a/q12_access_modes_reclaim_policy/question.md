# q12 — Access modes and reclaim policy

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q12_access_modes_reclaim_policy
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 1단계에서 PV 를 직접 만드는 것부터 시작하므로, setup 은 이전 흔적(파드 `writer`·`reader`, PVC `pvc-a`·`pvc-b`·`pvc-d`·`pvc-rwx`, PV `pv-retain`·`pv-delete`)과 worker01 의 `/mnt/data/retain`·`/mnt/data/delete` 를 지우고 namespace `ops` 만 준비한다.
`ops` 는 A11 도 쓰므로 setup·cleanup 은 namespace 를 지우지 않고 이 문제의 리소스만 이름으로 지운다. worker01 로 ssh 가 되고 그곳에서 암호 없는 sudo 가 되어야 한다. StorageClass `slow` 는 만들지 않는다(이 문제에서 `slow` 는 PV 에 붙이는 클래스 이름일 뿐이다).

## Task

A claim was deleted by mistake and its volume must be reused without losing the data.

1. Create two PersistentVolumes in class `slow`, both 1Gi, `ReadWriteOnce` and pinned to
   node `worker01` with node affinity: `pv-retain` with reclaim policy `Retain` on
   `hostPath` `/mnt/data/retain`, and `pv-delete` with reclaim policy `Delete` on
   `hostPath` `/mnt/data/delete`.
2. In namespace `ops`, create a claim `pvc-a` that is guaranteed to bind to `pv-retain`
   (not merely to any matching volume), write a file to it from a Pod `writer`
   (`busybox:1.36`), then delete the Pod and the claim.
3. Report the `STATUS` of `pv-retain` now, bring it back to `Available` without deleting
   the PV, and prove with a new claim `pvc-b` and a Pod `reader` that the file survived.
4. Bind a claim `pvc-d` to `pv-delete`, delete the claim, and report the `STATUS` of
   `pv-delete` together with the event that explains it.
5. Create a claim `pvc-rwx` in `ops` requesting `ReadWriteMany` from class `slow` and state
   in one line why it does not bind.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_pv_pvc_static_provisioning/question.md) · [q13 →](../q13_node_notready_kubelet/question.md)
