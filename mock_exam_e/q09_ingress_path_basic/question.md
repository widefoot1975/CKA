# q09 — Publish a Service with an Ingress

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q09_ingress_path_basic
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 클러스터에는 IngressClass `nginx` 가, `echo` 에는 Deployment `echo` 와 Service `echo-svc`(8080)가 있고 Ingress 는 없다. 문제 풀이에서 직접 만든다.
컨트롤러 Service `nginx-ingress`(ns `nginx-ingress`)는 NodePort 라 Ingress ADDRESS 가 비어 있을 수 있다. 그때는 아래처럼 `<노드IP>:<NodePort>` 로 curl 한다.

```bash
NP=$(kubectl -n nginx-ingress get svc nginx-ingress -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
NODE=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
curl -s -o /dev/null -w '%{http_code}\n' -H 'Host: example.org' http://$NODE:$NP/echo   # 200
```

NGINX Ingress Controller 는 다른 Ingress 문제에서도 쓰므로 정리할 때 `echo` 만 지운다.

## Task

Namespace `echo` contains Service `echo-svc`, which listens on port `8080` and returns HTTP `200`
for any path. An Ingress controller is installed in the cluster.

1. Find the name of the IngressClass that exists in the cluster.
2. Create an Ingress named `echo` in namespace `echo` that uses this IngressClass and sends
   requests for host `example.org` with path `/echo` (path type `Prefix`) to Service `echo-svc`
   on port `8080`.
3. Using `curl` against the Ingress controller with the header `Host: example.org`, confirm that
   path `/echo` returns HTTP `200`.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_httproute_path_routing/question.md) · [q10 →](../q10_service_named_targetport/question.md)
