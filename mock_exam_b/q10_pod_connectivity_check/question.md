# q10 — Verify pod-to-pod connectivity across namespaces

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q10_pod_connectivity_check
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

namespace·Deployment·Service·파드는 문제 1·2번에서 직접 만들어야 하므로 setup 은 지난 실습의 `alpha-web`·`probe` 를 지우고 답안 디렉터리 `/opt/q10/` 만 만든다.
`mock_exam_a/q10` 도 namespace `alpha`·`beta` 를 쓴다. 그 문제의 리소스가 남아 있으면 namespace 는 지우지 않고 그대로 두므로, 1번의 `kubectl create namespace` 가 `AlreadyExists` 를 내도 그대로 진행하면 된다.
NetworkPolicy 를 쓰지 않는 문제라 CNI 종류와 상관없이 풀 수 있다. 단, `alpha`·`beta` 에 다른 실습의 NetworkPolicy 가 남아 있으면 4번의 HTTP 요청이 막힌다.

## Task

A team claims pods in one namespace cannot talk to a service in another. Prove or
disprove it.

1. In namespace `alpha`, create deployment `alpha-web` (`nginx:1.27`, 2 replicas) and
   expose it as a ClusterIP service `alpha-web` on port `80`.
2. In namespace `beta`, create a long-running pod named `probe` using image
   `busybox:1.36` that does not restart.
3. From `probe`, resolve `alpha-web` using its **short name** and then its FQDN. Write
   both results and the resolved ClusterIP to `/opt/q10/dns.txt`.
4. Write the pod IPs currently backing the service, read from the EndpointSlice, to
   `/opt/q10/endpoints.txt`, then show an HTTP request from `probe` actually succeeding.
5. Write to `/opt/q10/triage.txt` the one decisive command for each of the three layers
   that can break this: DNS, Service/EndpointSlice, NetworkPolicy.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_networkpolicy_ingress_egress/question.md) · [q11 →](../q11_storageclass_dynamic_expand/question.md)
