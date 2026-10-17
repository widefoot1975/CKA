# q10 — Add a static DNS record with CoreDNS

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q10_coredns_hosts_entry
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

setup 을 처음 실행할 때 지금의 Corefile 을 `/opt/course/f10-corefile.orig` 에 보관하고, 다시 실행하거나 `cleanup.sh` 를 돌리면 그 원본으로 되돌린 뒤 CoreDNS 를 재시작한다. 그래서 setup 을 처음 돌리기 **전에** Corefile 을 직접 고쳐 두었다면 먼저 원래대로 돌려 놓는다.
`/opt/course/f10/` 는 빈 디렉터리로 만들어 두고, 백업 파일은 문제 1번에서 직접 만든다. CoreDNS 설정은 클러스터 전체에 영향을 주므로 실습이 끝나면 꼭 정리한다.

## Task

Pods in the cluster must be able to resolve the name `db.internal` to `10.0.0.50`. The
record must be served by the cluster DNS (CoreDNS); do not change the Pods' own
`/etc/hosts`.

1. Back up ConfigMap `coredns` in namespace `kube-system` to
   `/opt/course/f10/coredns-backup.yaml`.
2. Add a `hosts` entry to the Corefile in that ConfigMap so that `db.internal` resolves to
   `10.0.0.50`, while every other name keeps resolving as before.
3. Make sure CoreDNS uses the new configuration. Then verify from a temporary
   `busybox:1.36` Pod that `db.internal` resolves to `10.0.0.50` and that
   `kubernetes.default.svc.cluster.local` still resolves.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_networkpolicy_least_permissive/question.md) · [q11 →](../q11_pv_reclaim_policy_patch/question.md)
