# q16 — Cluster DNS stopped working

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q16_coredns_scaled_to_zero
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정이 끝나면 **클러스터의 모든 파드가 DNS 이름을 해석하지 못한다.** 다른 문제의 확인 단계에서 Service 이름(예: `http://payments`)을 쓰면 이 문제를 풀기 전까지 실패한다.
실습이 끝나면 **반드시 `cleanup.sh`** 로 CoreDNS 를 kubeadm 기본값인 2개로 되돌린다.

## Task

In cluster `k8s-c1`, pods can no longer resolve any DNS name, not even `kubernetes.default`.
Connections to pod IP addresses still work.

1. Find out why cluster DNS does not answer. Start from Service `kube-dns` in namespace
   `kube-system` and its EndpointSlice.
2. Fix the problem so that cluster DNS runs with `2` replicas again.
3. Write the kind and name of the object you had to fix, in the form `<kind>/<name>` (for example
   `daemonset/foo`), to `/opt/course/e16/cause.txt`.
4. From a temporary `busybox:1.36` pod, confirm that
   `nslookup kubernetes.default.svc.cluster.local` succeeds.

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

[↑ 문항 목록](../README.md) · [← q15](../q15_crashloop_wrong_command/question.md) · [q17 →](../q17_top_node_and_containers/question.md)
