# q10 — Point a Service at a named container port

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns api --ignore-not-found --wait=true
kubectl create ns api

# 1) Deployment backend: nginx:1.27, 컨테이너 이름 nginx, ports 선언 없음
kubectl -n api create deploy backend --image=nginx:1.27
kubectl -n api rollout status deploy backend --timeout=120s

# 2) 시작 상태 확인: 컨테이너 ports 가 비어 있고 Service 가 없어야 함
kubectl -n api get deploy backend -o jsonpath='{.spec.template.spec.containers[0].name} ports={.spec.template.spec.containers[0].ports}{"\n"}'
kubectl -n api get svc
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `api` 에는 Deployment `backend`(컨테이너 `nginx`, 80에서 듣지만 `ports` 선언 없음)만 있고
Service 는 없다. 포트 이름 `http` 는 문제 1단계에서 직접 선언한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns api --ignore-not-found
```

</details>

## Task

Deployment `backend` in namespace `api` runs `nginx:1.27` in a container named `nginx`, which
listens on port 80. The container spec does not declare any ports yet.

1. Add a container port `80` named `http` (protocol `TCP`) to container `nginx` of Deployment
   `backend`.
2. Create a ClusterIP Service named `backend` in namespace `api` that listens on port `8080` and
   targets the container port **by its name** `http`.
3. Confirm that the Service's EndpointSlice resolves the target to port `80`, and that
   `http://backend.api:8080` returns the nginx welcome page from a temporary `busybox:1.36` pod.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
