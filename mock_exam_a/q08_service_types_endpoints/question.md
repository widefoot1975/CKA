# q08 — Service types and endpoint inspection

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
A15·C06 도 `shop` 에 Deployment `api` 를 만든다. 이 문제의 setup 은 namespace `shop` 을 통째로 지우므로 `shop` 을 쓰는 다른 문제(A15·C06·C08·D05·E08·F15)와 동시에 펼쳐 두지 않는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q08_service_types_endpoints
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 Deployment 와 Service 네 개를 모두 직접 만드는 것부터 시작하므로, setup 은 이전 흔적을 지우고 nodePort 31080 과
LoadBalancer 구현체 유무만 확인한다. 설정 직후 `shop` 은 없다. `shop` 은 D05 와 같은 이름이므로 두 문제를 동시에 펼쳐 두지 않는다.

## Task

Namespace `shop` needs the same set of pods reachable four different ways.

1. Create a Deployment `api` in `shop` with 3 replicas of `nginx:1.27`, container port 80.
2. Create a ClusterIP Service `api-clusterip` on port 8080 forwarding to container port 80.
3. Create a NodePort Service `api-nodeport`, service port 8080, target port 80, fixed node
   port 31080.
4. Create a headless Service `api-headless` for the same pods on port 8080.
5. Create a LoadBalancer Service `api-lb` on port 80 and record its `EXTERNAL-IP`.
6. List the three backing pod IPs of `api-clusterip`, once through its Endpoints and once
   through its EndpointSlice.
7. Reach `api-clusterip` from a temporary pod and `api-nodeport` from a node, and state in
   one line what `EXTERNAL-IP` shows for `api-lb` and why.

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

[↑ 문항 목록](../README.md) · [← q07](../q07_taint_toleration_affinity/question.md) · [q09 →](../q09_ingress_path_routing/question.md)
