# q02 — Apply a Kustomize overlay

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q02_kustomize_overlay_basic
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/e02/base/` 에 파일 3개가 있고 `overlays/staging/` 은 비어 있다. namespace `staging` 은 아직 없다(문제에서 직접 만든다).

## Task

A Kustomize base for the application `api` exists in `/opt/course/e02/base/`: Deployment `api`
(image `nginx:1.27`, 1 replica), Service `api` and a `kustomization.yaml`. Do not modify any file
under `base/`.

1. Create `/opt/course/e02/overlays/staging/kustomization.yaml` that uses the base and
   - places all resources in namespace `staging`,
   - sets Deployment `api` to `2` replicas,
   - changes the image `nginx` to `nginx:1.28`,
   - adds the label `env: staging` to all resources **without** changing any selector.
2. Create namespace `staging` and render the overlay with `kubectl kustomize` to check it.
3. Apply the overlay with `kubectl apply -k` and confirm that Deployment `api` in `staging` has
   2 ready replicas running `nginx:1.28`.

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

[↑ 문항 목록](../README.md) · [← q01](../q01_cri_dockerd_node_prep/question.md) · [q03 →](../q03_crd_install_custom_resource/question.md)
