# q03 — Install a CRD and create a custom resource

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
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q03_crd_install_custom_resource
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/e03/crd.yaml` 만 있고 CRD `widgets.demo.example.com` 은 아직 설치되지 않았다. `apiversion.txt` 는 문제에서 직접 만든다.

## Task

The file `/opt/course/e03/crd.yaml` contains a CustomResourceDefinition for
`widgets.demo.example.com`.

1. Install the CRD and confirm that the API server now serves the resource in API group
   `demo.example.com`.
2. In namespace `default`, create a `Widget` named `blue-small` with `spec.color: blue` and
   `spec.size: 1`.
3. List the Widgets in `default` using the resource's short name.
4. Write the `apiVersion` you used for the Widget to `/opt/course/e03/apiversion.txt`.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_kustomize_overlay_basic/question.md) · [q04 →](../q04_ha_control_plane_inspect/question.md)
