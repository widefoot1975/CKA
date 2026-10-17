# q15 — A Service with no endpoints

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
A08·C06 도 `shop` 에 Deployment `api` 를 만들므로 세 문제를 동시에 펼쳐 두지 않는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q15_service_no_endpoints
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `shop` 에는 Deployment `api`(파드 3개, Ready)와 Service `api-svc`(port 80)가 있고, EndpointSlice 의 ENDPOINTS 는 비어 있다.
`shop` 은 A08·C08·D05·E08·F15 도 쓰는 namespace 라서 setup·cleanup 은 namespace 를 통째로 지우지 않고 `api`·`api-svc` 만 지운다.
다만 A08 도 Deployment `api` 를 만들므로 A08 과는 동시에 펼쳐 두지 않는다. cleanup 은 `shop` 에 다른 리소스가 없을 때만 namespace 를 지운다.

## Task

Service `api-svc` in namespace `shop` accepts connections but every client gets
`connection refused`. Three pods of Deployment `api` are running.

1. Show that the Service has no endpoints, once through its Endpoints object and once
   through its EndpointSlice.
2. Compare the Service selector against the labels actually present on the pods.
3. Report whether the pods are `Ready`.
4. Compare the Service `targetPort` against the port the container actually listens on.
5. Fix the Service so three endpoints appear. Do not relabel, restart or recreate the pods.
6. Write in one line the two independent reasons an endpoint list can be empty.

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

[↑ 문항 목록](../README.md) · [← q14](../q14_pod_crashloopbackoff/question.md) · [q16 →](../q16_container_log_streams/question.md)
