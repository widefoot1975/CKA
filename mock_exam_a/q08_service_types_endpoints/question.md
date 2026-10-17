# q08 — Service types and endpoint inspection

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
A15·C06 도 `shop` 에 Deployment `api` 를 만든다. 이 문제의 setup 은 namespace `shop` 을 통째로 지우므로 `shop` 을 쓰는 다른 문제(A15·C06·C08·D05·E08·F15)와 동시에 펼쳐 두지 않는다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 — 이 문제는 namespace shop 부터 직접 만든다
#    (D05 도 shop 을 쓰므로 D05 실습 상태도 함께 지워진다)
kubectl delete ns shop --ignore-not-found --wait=true

# 1) nodePort 31080 을 다른 Service 가 쓰고 있지 않은지 확인 (쓰고 있으면 3단계가 실패한다)
kubectl get svc -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name} {.spec.ports[*].nodePort}{"\n"}{end}' \
  | grep -w 31080 && echo "nodePort 31080 사용 중 — 위 Service 를 먼저 정리할 것" || echo "nodePort 31080 비어 있음 (정상)"

# 2) LoadBalancer 구현체(MetalLB 등)가 있는지 확인 — 없으면 api-lb 의 EXTERNAL-IP 는 <pending> 이 정상
kubectl get pods -A 2>/dev/null | grep -i metallb || echo "LoadBalancer 구현체 없음 → EXTERNAL-IP <pending> 예상"

# 3) 시작 상태 확인: namespace shop 이 없어야 함
kubectl get ns shop 2>/dev/null || echo "namespace shop 없음 (정상)"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 Deployment 와 Service 네 개를 모두 직접 만드는 것부터 시작하므로, setup 은 이전 흔적을 지우고 nodePort 31080 과
LoadBalancer 구현체 유무만 확인한다. 설정 직후 `shop` 은 없다. `shop` 은 D05 와 같은 이름이므로 두 문제를 동시에 펼쳐 두지 않는다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns shop --ignore-not-found
```

</details>

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

---

Solution → **[solution.md](solution.md)**
