# q02 — Deploy an environment overlay with Kustomize

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q02_kustomize_overlay_deploy
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/q02/base/` 에 파일 3개가 있고 `overlays/prod/` 는 비어 있다. namespace `prod-web` 은 아직 없다(문제에서 직접 만든다).

## Task

A base manifest set exists at `/opt/course/q02/base/` containing `deployment.yaml`
(Deployment `web`, image `nginx:1.25`, 1 replica), `service.yaml` and
`kustomization.yaml`.

Build a production overlay at `/opt/course/q02/overlays/prod/` that, without editing
any file under `base/`:

1. References the base.
2. Deploys into namespace `prod-web` (create the namespace).
3. Prefixes every resource name with `prod-`.
4. Adds the label `env: prod` to every resource.
5. Sets the `web` Deployment to 4 replicas.
6. Changes the image to `nginx:1.27`.
7. Adds a ConfigMap generated from literals `TIER=prod` and `LOG_LEVEL=warn`,
   named `web-config`.
8. Patches the container port to `8080` using a patch with an explicit `target`.

Render the overlay to stdout to review it **before** applying, then apply it.

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

[↑ 문항 목록](../README.md) · [← q01](../q01_kubeadm_worker_join/question.md) · [q03 →](../q03_cni_install_networkpolicy/question.md)
