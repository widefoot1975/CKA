# q03 — Install a CRD and create a custom resource

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q03_crd_custom_resource
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `cka` 와 빈 디렉터리 `/opt/q03` 만 있다. CRD 는 아직 없어서 마지막 `kubectl api-resources` 는 머리글만 출력한다. CRD 와 `Exercise`, `crd.txt` 는 문제에서 직접 만든다.
CRD 이름을 적으면 `metadata.name` 형식이라는 답이 드러나므로, 스크립트는 이름 대신 그룹(`training.example.com`)으로 CRD 를 찾아 지운다. namespace `cka` 는 이 문제만 쓴다.

## Task

A training team wants to track drills as first-class Kubernetes objects.

1. Create a CustomResourceDefinition with group `training.example.com`, version `v1`,
   scope `Namespaced`, kind `Exercise`, plural `exercises`, singular `exercise` and
   short name `ex`.
2. The schema must accept `spec.topic` (string, **required**) and `spec.minutes`
   (integer, default `30`). Any other field under `spec` must not be stored.
3. Add two additional printer columns so `kubectl get exercises` shows `TOPIC`
   (`.spec.topic`) and `MINUTES` (`.spec.minutes`).
4. In namespace `cka`, create an `Exercise` named `networkpolicy-drill` with
   `topic: networking` and no `minutes` field.
5. Write the API group/version that serves this resource, and the value `minutes` ended
   up with, to `/opt/q03/crd.txt`.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_node_prerequisites_containerd/question.md) · [q04 →](../q04_crictl_container_runtime/question.md)
