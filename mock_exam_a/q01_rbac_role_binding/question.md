# q01 — Namespaced RBAC for a deployment operator

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (ServiceAccount·Role·RoleBinding 도 네임스페이스와 함께 지워진다)
kubectl delete ns staging --ignore-not-found --wait=true
kubectl create ns staging

# 1) 스케일 권한을 실제로 시험해 볼 Deployment
kubectl -n staging create deployment web --image=nginx:1.27 --replicas=1
kubectl -n staging rollout status deploy web --timeout=120s

# 2) 시작 상태 확인: Deployment web 만 있고 deploy-bot·Role·RoleBinding 은 없어야 한다
kubectl -n staging get sa,role,rolebinding,deploy
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `staging` 에는 Deployment `web`(`nginx:1.27`, 1개)만 있고 `deploy-bot`, `deployment-operator`, `deploy-bot-binding` 은 없다. `web` 은 문제 4번에서 실제로 스케일해 볼 대상이다.
`mock_exam_e/q02` 도 namespace `staging` 을 쓰므로, 두 문제를 이어서 풀면 나중에 돌린 setup 이 앞 문제의 결과를 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns staging --ignore-not-found
```

</details>

## Task

A deployment automation tool needs limited access to the `staging` namespace.

1. Create a ServiceAccount named `deploy-bot` in the `staging` namespace.
2. Create a Role named `deployment-operator` granting
   - `get`, `list`, `watch`, `update` and `patch` on `deployments`
   - `update` and `patch` on `deployments/scale`
   - `get` and `list` on `pods`
3. Bind the Role to the ServiceAccount with a RoleBinding named `deploy-bot-binding`.
4. Verify that `deploy-bot` can scale a deployment in `staging` but **cannot** delete
   deployments, and **cannot** read deployments in the `default` namespace.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
