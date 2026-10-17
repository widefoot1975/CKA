# q08 — Move an HTTP Ingress to an HTTPRoute

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q08_ingress_to_httproute_simple
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `gateway` 에는 Gateway `public-gw` 가, `blog` 에는 Deployment·Service `blog`(80)와 `blog-api`(8080), 그리고 옮길 대상인 Ingress `blog` 가 있다. HTTPRoute 는 없고 문제 풀이에서 직접 만든다.
Ingress `blog` 는 옮길 규칙을 읽어 오는 원본일 뿐이라 Ingress 컨트롤러는 설치하지 않는다(ADDRESS 가 비어 있어도 정상).
NGINX Gateway Fabric 은 `gateway` 안에 데이터 플레인 Service(`public-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `<노드IP>:<NodePort>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `gateway` 와 `blog` 만 지운다.

## Task

In namespace `blog`, Ingress `blog` publishes host `blog.example.com`: path `/` goes to
Service `blog` on port `80`, and path `/api` goes to Service `blog-api` on port `8080`.
The platform team runs Gateway `public-gw` in namespace `gateway`. Its listener `http`
(protocol HTTP, port 80) accepts routes from all namespaces. Service `blog` answers every
request with `blog-web`, Service `blog-api` answers every request with `blog-api`.

1. Create HTTPRoute `blog` in namespace `blog`, attached to listener `http` of Gateway
   `public-gw` in namespace `gateway`, with the same hostname and the same two path rules
   as Ingress `blog`.
2. Using the address of Gateway `public-gw` and the header `Host: blog.example.com`,
   verify that `/` reaches `blog` and `/api` reaches `blog-api`.
3. After the verification succeeds, delete Ingress `blog`.

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

[↑ 문항 목록](../README.md) · [← q07](../q07_cronjob_manual_trigger/question.md) · [q09 →](../q09_networkpolicy_least_permissive/question.md)
