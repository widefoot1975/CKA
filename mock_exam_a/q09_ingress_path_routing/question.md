# q09 — Route traffic with an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q09_ingress_path_routing
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 IngressClass `nginx` 가 있고, namespace `web` 은 있지만 이 문제의 Deployment·Service·Ingress 는 없다.
1단계부터 직접 만든다. namespace `web` 은 b05, d08, f06 도 쓰므로 setup 과 cleanup 은 namespace 를 통째로 지우지 않고
이 문제의 리소스(`site`, `api`, `site-svc`, `api-svc`, `shop-ingress`)만 지운다. 다른 문제와 동시에 풀지 않는 편이 깔끔하다.

컨트롤러 Service `nginx-ingress`(ns `nginx-ingress`)는 NodePort 라 Ingress ADDRESS 가 비어 있을 수 있다. 그때는 아래처럼
`<노드IP>:<NodePort>` 로 curl 한다.

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: shop.example.com' http://$NODE:$NP/    # Ingress 를 만든 뒤 실행
```

NGINX Ingress Controller 는 다른 Ingress 문제에서도 쓰므로 정리할 때 남겨 둔다.

## Task

Two applications in namespace `web` must share one hostname.

1. Create Deployments `site` and `api` in `web`, 2 replicas each, image
   `registry.k8s.io/e2e-test-images/echoserver:2.5`, container port 8080.
2. Expose each with a ClusterIP Service on port 80 targeting 8080, named `site-svc` and
   `api-svc`.
3. Find the IngressClass available in this cluster and note its name.
4. Create an Ingress `shop-ingress` in `web` for host `shop.example.com` on that class:
   `/` and everything below it → `site-svc:80`, `/api` and everything below → `api-svc:80`.
5. Add a rule routing exactly `/health` to `api-svc:80`; `/health/extra` must not match.
6. Verify all three paths with `curl` and a `Host` header.
7. State in one line what happens if `pathType` is left out of a rule.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_service_types_endpoints/question.md) · [q10 →](../q10_coredns_service_discovery/question.md)
