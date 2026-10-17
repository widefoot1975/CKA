# q13 — Cluster DNS resolution is failing

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` (→ `ssh <node>` if needed) |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q13_coredns_resolution_failure
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

setup 을 처음 실행할 때 지금의 Corefile 을 `/opt/course/c13-corefile.orig` 에 보관하고, 다시 실행하거나 `cleanup.sh` 를 돌리면 그 원본으로 되돌린 뒤 CoreDNS 를 재시작한다. 그래서 setup 을 처음 돌리기 **전에** Corefile 을 직접 고쳐 두었다면 먼저 원래대로 돌려 놓는다. CoreDNS 레플리카가 0 이면(e16 실습을 정리하지 않은 상태) kubeadm 기본값 2 로 되돌린다.
설정이 끝나면 **클러스터의 모든 파드가 DNS 이름을 해석하지 못한다.** 확인용으로 namespace `app` 에 Service `backend` 와 nginx 파드 하나를 만든다. 파드 IP 는 문제의 `10.244.2.14` 와 다를 수 있으니 setup 이 출력한 값을 쓴다.
namespace `app` 은 f09 도 쓴다. 이 문제가 만든 리소스에는 라벨 `course=c13` 이 붙고, `cleanup.sh` 는 그것만 지운다(namespace 는 이 문제가 만들었을 때만 지운다). 실습이 끝나면 **반드시 `cleanup.sh`** 로 Corefile 을 되돌린다.

## Task

Pods across the cluster cannot resolve any name. `curl http://backend.app.svc.cluster.local`
fails with a lookup error from inside every pod, but `curl http://10.244.2.14` (a pod IP)
works. External names such as `kubernetes.io` also fail.

1. Confirm from inside a pod that this is a DNS failure and not a routing failure.
2. Work out which layer is broken: the pod's resolver config, the `kube-dns` Service, the
   CoreDNS pods, or the CoreDNS configuration.
3. Fix the cluster so that both in-cluster Service names and external names resolve.
4. Write the root cause in one sentence to `/opt/course/q13/cause.txt`.
5. Do not delete the `kube-dns` Service and do not change any pod's `dnsPolicy`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_pvc_expand_reclaim_behavior/question.md) · [q14 →](../q14_oomkilled_resource_analysis/question.md)
