# q01 — Namespaced RBAC for a deployment operator

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q01_rbac_role_binding
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `staging` 에는 Deployment `web`(`nginx:1.27`, 1개)만 있고 `deploy-bot`, `deployment-operator`, `deploy-bot-binding` 은 없다. `web` 은 문제 4번에서 실제로 스케일해 볼 대상이다.
`mock_exam_e/q02` 도 namespace `staging` 을 쓰므로, 두 문제를 이어서 풀면 나중에 돌린 setup 이 앞 문제의 결과를 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [q02 →](../q02_kubeadm_cluster_upgrade/question.md)
