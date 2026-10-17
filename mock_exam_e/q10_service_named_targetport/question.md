# q10 — Point a Service at a named container port

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q10_service_named_targetport
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `api` 에는 Deployment `backend`(컨테이너 `nginx`, 80에서 듣지만 `ports` 선언 없음)만 있고
Service 는 없다. 포트 이름 `http` 는 문제 1단계에서 직접 선언한다.

## Task

Deployment `backend` in namespace `api` runs `nginx:1.27` in a container named `nginx`, which
listens on port 80. The container spec does not declare any ports yet.

1. Add a container port `80` named `http` (protocol `TCP`) to container `nginx` of Deployment
   `backend`.
2. Create a ClusterIP Service named `backend` in namespace `api` that listens on port `8080` and
   targets the container port **by its name** `http`.
3. Confirm that the Service's EndpointSlice resolves the target to port `80`, and that
   `http://backend.api:8080` returns the nginx welcome page from a temporary `busybox:1.36` pod.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_ingress_path_basic/question.md) · [q11 →](../q11_retained_pv_reuse/question.md)
