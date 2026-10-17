# q05 — Scale, update and roll back a Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q05_deployment_scale_rollout_undo
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `shop` 에는 Deployment `web`(컨테이너 `nginx`, 이미지 `nginx:1.27`, 레플리카 2) 하나만 있고
`rollout history` 에는 리비전 1 하나만 보인다. 변경 사유 어노테이션은 아직 없다.

## Task

Namespace `shop` contains Deployment `web` (image `nginx:1.27`, 2 replicas).

1. Scale `web` to 4 replicas.
2. Update the image of its container to `nginx:1.28` and record the change cause
   `upgrade to 1.28` on the Deployment so that it appears in the rollout history.
3. Roll `web` back to the previous revision.
4. Confirm that `web` runs image `nginx:1.27` again with 4 ready replicas.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_kubeadm_cert_renewal/question.md) · [q06 →](../q06_configmap_env_and_volume/question.md)
