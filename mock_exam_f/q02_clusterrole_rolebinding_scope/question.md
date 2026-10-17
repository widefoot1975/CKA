# q02 — Reuse a ClusterRole inside one namespace

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q02_clusterrole_rolebinding_scope
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `team-a` 에 Deployment `web-a`, `team-b` 에 `web-b` 가 있고, `deployment-viewer` 와 `anna-deploy-view` 는 없다. `dev-anna` 는 아직 아무 권한이 없어 `can-i` 가 모두 `no` 다.
실수로 ClusterRoleBinding `anna-deploy-view` 를 만들었어도 `setup.sh`·`cleanup.sh` 가 함께 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q01](../q01_helm_template_without_crds/question.md) · [q03 →](../q03_kubeadm_upgrade_worker/question.md)
