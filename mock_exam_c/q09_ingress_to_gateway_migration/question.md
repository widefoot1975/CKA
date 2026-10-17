# q09 — Migrate a TLS Ingress to the Gateway API

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q09_ingress_to_gateway_migration
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `secure` 에는 Deployment `portal`(3 레플리카), Service `portal`(80), TLS Secret `portal-tls`, 그리고 옮길 대상인 Ingress `portal-ing` 가 있다. Gateway 와 HTTPRoute 는 없고 문제 풀이에서 직접 만든다.
`portal-tls` 는 setup 이 `openssl` 로 만든 자체 서명 인증서(CN·SAN `portal.example.com`)라 curl 할 때 `-k` 가 필요하다.
은퇴한 Ingress NGINX 를 흉내 낸 것이라 Ingress 컨트롤러는 설치하지 않는다. Ingress 는 옮길 값을 읽어 오는 원본일 뿐이다(ADDRESS 가 비어 있어도 정상).
NGINX Gateway Fabric 은 `secure` 안에 데이터 플레인 Service(`portal-gw-nginx`, NodePort)를 만든다.
LoadBalancer 가 없는 실습 클러스터라 Gateway 주소로 curl 이 닿지 않으면 `--resolve portal.example.com:<NodePort>:<노드IP>` 로 확인한다.
NGINX Gateway Fabric 은 다른 Gateway 문제에서도 쓰므로 정리할 때 `secure` 와 `/opt/course/q09` 만 지운다.

## Task

Namespace `secure` serves Deployment `portal` (3 replicas, `nginx:1.27`, port 80) through
Service `portal` (port 80) and Ingress `portal-ing` (IngressClass `nginx`), which
terminates TLS for `portal.example.com` with Secret `portal-tls`. The Ingress NGINX
controller has been retired, so the site must move to the Gateway API. GatewayClass
`nginx` is installed and `Accepted`.

1. From the existing Ingress, write the host, the TLS Secret, and the backend Service and
   port it uses to `/opt/course/q09/ingress.txt`.
2. Create a Gateway `portal-gw` in `secure` with gatewayClassName `nginx` and one listener
   named `https`: protocol `HTTPS`, port `443`, hostname `portal.example.com`, terminating
   TLS with Secret `portal-tls`.
3. Create an HTTPRoute `portal-route` in `secure`, attached to the `https` listener, for
   hostname `portal.example.com`, sending path prefix `/` to Service `portal` on port 80.
4. Verify that HTTPS through the Gateway serves the page, that the presented certificate's
   subject is `portal.example.com`, and that the listener reports `ResolvedRefs=True` and
   `Programmed=True`.
5. Delete the Ingress only after step 4 succeeds.
6. State in one line what you would additionally need if `portal-tls` lived in namespace
   `certs` instead of `secure`.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_httproute_traffic_split/question.md) · [q10 →](../q10_headless_service_statefulset_dns/question.md)
