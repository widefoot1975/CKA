# q15 — Endpoints exist but connections are refused

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (트러블슈팅 문제라 명령어에 답이 보인다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

<details><summary>설정 명령 펼치기 (답 포함)</summary>

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns shop --ignore-not-found --wait=true
kubectl create ns shop

# 1) Deployment payments: nginx 2개 (label app=payments, nginx 는 80 에서 듣는다)
kubectl -n shop create deployment payments --image=nginx:1.27 --replicas=2 --port=80

# 2) Service payments: port 80 → targetPort 8080 (selector app=payments)
kubectl -n shop create service clusterip payments --tcp=80:8080

kubectl -n shop rollout status deploy payments --timeout=120s

# 3) 시작 상태 확인: 파드 2개 Ready, EndpointSlice 에 주소가 있음
kubectl -n shop get deploy,pod,svc
kubectl -n shop get endpointslice -l kubernetes.io/service-name=payments
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `shop` 에는 Deployment `payments`(nginx 2개, Ready)와 Service `payments`(port 80)가 있고 EndpointSlice 에 파드 주소 두 개가 보인다. 그래도 Service 로 가는 요청은 거부된다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns shop --ignore-not-found
```

</details>

## Task

In namespace `shop`, Deployment `payments` runs 2 Pods (image `nginx:1.27`, label
`app=payments`) that are `Running` and `Ready`. Service `payments` (port `80`) selects
them and has endpoints, but every request to the Service fails with `connection refused`.

1. Find out why requests are refused although the Service has endpoints.
2. Fix Service `payments`. Do not change the Deployment.
3. Verify that the EndpointSlice of `payments` now lists the port the Pods actually
   listen on, and that `wget -qO- http://payments` from a temporary `busybox:1.36` Pod in
   namespace `shop` returns the nginx welcome page.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
