# q10 — Allow traffic to a backend from one frontend only

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q10_networkpolicy_allow_from_label
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `proj` 에는 파드 `backend`(8080 에서 `backend` 문자열 응답), `frontend`, `other` 와 NetworkPolicy `deny-all` 이 있고 `allow-frontend` 는 없다.
마지막 확인에서 frontend 의 요청이 응답을 받으면 CNI 가 NetworkPolicy 를 지원하지 않는 것이다(flannel 등). 이 문제는 Calico·Cilium 같은 CNI 에서 풀어야 의미가 있다.

## Task

Namespace `proj` contains three pods: `backend` (label `app=backend`, serves HTTP on port
`8080`), `frontend` (label `app=frontend`) and `other` (label `app=other`). `frontend` and
`other` run `busybox:1.36`. A NetworkPolicy `deny-all` already blocks all ingress traffic in the
namespace.

1. Create a NetworkPolicy `allow-frontend` in `proj` that applies to pods labelled `app=backend`.
2. It must allow ingress on TCP port `8080` only from pods labelled `app=frontend` in the same
   namespace. Do not modify or delete `deny-all`.
3. Verify that `frontend` can reach `backend` on port 8080 and that the same request from
   `other` times out.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_nodeport_expose_container_port/question.md) · [q11 →](../q11_storageclass_default_wffc/question.md)
