# q09 — Publish a container port with a NodePort Service

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q09_nodeport_expose_container_port
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `spline` 에는 Deployment `front-end`(컨테이너 `nginx`, `ports` 없음, 파드 2개)만 있고 Service 는 없다.
2단계에서 `30080` 을 쓰는 Service 가 출력되면 그 Service 를 먼저 지우거나 다른 실습을 정리한 뒤 푼다.

## Task

Namespace `spline` contains Deployment `front-end` (image `nginx:1.27`, container name `nginx`).
Its pod template does not declare any container ports.

1. Update the Deployment so that container `nginx` declares containerPort `80`, named `http`,
   protocol `TCP`.
2. Create a Service `front-end-svc` of type `NodePort` in `spline` that selects the `front-end`
   pods and maps port `80` to targetPort `80`, using the fixed nodePort `30080`.
3. Verify that the Service has endpoints and that `http://<node IP>:30080` returns the nginx
   welcome page.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_gateway_httproute_basic/question.md) · [q10 →](../q10_networkpolicy_allow_from_label/question.md)
