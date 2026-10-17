# q02 — Reuse a ClusterRole inside one namespace

| Item | Value |
|---|---|
| Exam | mock_exam_f |
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
# 0) 이전 실습 흔적 정리 (ClusterRole·ClusterRoleBinding 은 클러스터 범위라 따로 지운다)
kubectl delete clusterrolebinding anna-deploy-view --ignore-not-found
kubectl delete clusterrole deployment-viewer --ignore-not-found
kubectl delete ns team-a team-b --ignore-not-found --wait=true

# 1) 네임스페이스 두 개와, 읽어 볼 Deployment 하나씩
kubectl create ns team-a
kubectl create ns team-b
kubectl -n team-a create deployment web-a --image=nginx:1.27
kubectl -n team-b create deployment web-b --image=nginx:1.27

# 2) 시작 상태 확인: dev-anna 는 아직 아무 권한이 없다 (모두 no)
kubectl auth can-i list deployments -n team-a --as=dev-anna || true
kubectl auth can-i list deployments -n team-b --as=dev-anna || true
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `team-a` 에 Deployment `web-a`, `team-b` 에 `web-b` 가 있고, `deployment-viewer` 와 `anna-deploy-view` 는 없다. `dev-anna` 는 아직 아무 권한이 없어 `can-i` 가 모두 `no` 다.
실수로 ClusterRoleBinding `anna-deploy-view` 를 만들었어도 `setup.sh`·`cleanup.sh` 가 함께 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete clusterrolebinding anna-deploy-view --ignore-not-found
kubectl delete clusterrole deployment-viewer --ignore-not-found
kubectl delete ns team-a team-b --ignore-not-found
```

</details>

## Task

User `dev-anna` needs read-only access to Deployments, but only in namespace `team-a`.
Namespaces `team-a` and `team-b` already exist. The permissions must be defined once, at
cluster level, so that they can be reused for other namespaces later.

1. Create ClusterRole `deployment-viewer` that allows the verbs `get`, `list` and `watch`
   on `deployments` in API group `apps`.
2. Grant `deployment-viewer` to user `dev-anna` **only in namespace `team-a`**, using a
   binding named `anna-deploy-view`.
3. Verify with `kubectl auth can-i ... --as=dev-anna` that `dev-anna` can list Deployments
   in `team-a`, but not in `team-b` and not across all namespaces.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
