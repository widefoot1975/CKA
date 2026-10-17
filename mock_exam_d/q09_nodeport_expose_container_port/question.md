# q09 — Publish a container port with a NodePort Service

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns spline --ignore-not-found --wait=true
kubectl create ns spline

# 1) Deployment front-end: nginx:1.27, 컨테이너 이름 nginx, ports 선언 없음 (--port 를 주지 않는다)
kubectl -n spline create deploy front-end --image=nginx:1.27 --replicas=2
kubectl -n spline rollout status deploy front-end --timeout=120s

# 2) nodePort 30080 을 다른 Service 가 쓰고 있지 않은지 확인 (쓰고 있으면 문제 2단계가 실패한다)
kubectl get svc -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name} {.spec.ports[*].nodePort}{"\n"}{end}' \
  | grep -w 30080 && echo "nodePort 30080 사용 중 — 위 Service 를 먼저 정리할 것" || echo "nodePort 30080 비어 있음 (정상)"

# 3) 시작 상태 확인: 컨테이너 ports 가 비어 있고 Service 가 없어야 함
kubectl -n spline get deploy front-end -o jsonpath='{.spec.template.spec.containers[0].name} ports={.spec.template.spec.containers[0].ports}{"\n"}'
kubectl -n spline get svc
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `spline` 에는 Deployment `front-end`(컨테이너 `nginx`, `ports` 없음, 파드 2개)만 있고 Service 는 없다.
2단계에서 `30080` 을 쓰는 Service 가 출력되면 그 Service 를 먼저 지우거나 다른 실습을 정리한 뒤 푼다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns spline --ignore-not-found
```

</details>

## Task

Namespace `spline` contains Deployment `front-end` (image `nginx:1.27`, container name `nginx`).
Its pod template does not declare any container ports.

1. Update the Deployment so that container `nginx` declares containerPort `80`, named `http`,
   protocol `TCP`.
2. Create a Service `front-end-svc` of type `NodePort` in `spline` that selects the `front-end`
   pods and maps port `80` to targetPort `80`, using the fixed nodePort `30080`.
3. Verify that the Service has endpoints and that `http://<node IP>:30080` returns the nginx
   welcome page.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
