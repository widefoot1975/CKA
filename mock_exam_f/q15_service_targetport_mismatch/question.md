# q15 — Endpoints exist but connections are refused

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q15_service_targetport_mismatch
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `shop` 에는 Deployment `payments`(nginx 2개, Ready)와 Service `payments`(port 80)가 있고 EndpointSlice 에 파드 주소 두 개가 보인다. 그래도 Service 로 가는 요청은 거부된다.

## Task

In namespace `shop`, Deployment `payments` runs 2 Pods (image `nginx:1.27`, label
`app=payments`) that are `Running` and `Ready`. Service `payments` (port `80`) selects
them and has endpoints, but every request to the Service fails with `connection refused`.

1. Find out why requests are refused although the Service has endpoints.
2. Fix Service `payments`. Do not change the Deployment.
3. Verify that the EndpointSlice of `payments` now lists the port the Pods actually
   listen on, and that `wget -qO- http://payments` from a temporary `busybox:1.36` Pod in
   namespace `shop` returns the nginx welcome page.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_kubeconfig_wrong_port/question.md) · [q16 →](../q16_multicontainer_logs_prefix/question.md)
