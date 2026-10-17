# q09 — Restrict both ingress and egress with NetworkPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q09_networkpolicy_ingress_egress
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `payments` 에는 파드·Service `api`(8080, HTTP)와 `db`(5432, TCP)가, `frontend` 에는 파드 `web` 이, `scanner` 에는 파드 `probe` 가 있다. `web` 과 `probe` 는 둘 다 라벨이 `app=web` 이다. NetworkPolicy 는 하나도 없어서 마지막 확인에서는 `probe` 도 `api` 에 닿고(HTTP 200) `api` 도 `db` 에 닿는다.
모든 파드는 `curl`·`nc`·`nslookup` 이 들어 있는 `nicolaka/netshoot:v0.13` 이미지를 쓴다(처음 받을 때 시간이 조금 걸린다). 정책을 만든 뒤 차단이 안 되면 CNI 가 NetworkPolicy 를 지원하지 않는 것이다(flannel 등). Calico·Cilium 같은 CNI 에서 풀어야 의미가 있다.

## Task

Namespace `payments` holds pod `api` (label `app=api`, listening on `8080`) and pod `db`
(label `app=db`, listening on `5432`), exposed by Services `api` (port `8080`) and `db`
(port `5432`). Namespace `frontend` (label `kubernetes.io/metadata.name=frontend`) holds
pod `web` (label `app=web`). Namespace `scanner` holds pod `probe` (label `app=web`).

Lock `payments` down without changing any pod.

1. Create a policy named `default-deny-all` in `payments` that denies all ingress and all
   egress for every pod in the namespace.
2. Create a policy named `api-allow` in `payments` that allows ingress to `app=api` on
   TCP `8080` **only** from pods labelled `app=web` **in namespace `frontend`** — pod
   `probe` in `scanner` must stay blocked.
3. In the same policy, allow egress from `app=api` to `app=db` in `payments` on TCP `5432`,
   and allow DNS resolution for `app=api` (UDP and TCP `53` towards `kube-system`).
4. Create a policy named `db-allow` in `payments` that lets `app=db` accept TCP `5432`
   **only** from `app=api`.
5. Verify: `web` reaches `api:8080`, `probe` does not, `api` reaches `db:5432`, `api`
   resolves `db.payments.svc.cluster.local`, and `api` cannot reach anything else.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_gateway_api_httproute/question.md) · [q10 →](../q10_pod_connectivity_check/question.md)
