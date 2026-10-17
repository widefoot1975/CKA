# q06 — Update configuration and lock it

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q06_configmap_update_immutable
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 파드 안에서 `LOG_LEVEL=debug` 가 보인다. immutable ConfigMap 은 되돌릴 수 없어서 setup 이 ConfigMap `app-config` 와 Deployment `api` 를 지우고 다시 만든다.
namespace `web` 은 A06·A09·B05·D08 도 쓰므로 namespace 는 이 setup 이 만들었고 비어 있을 때만 지운다.
`mock_exam_a/q06` 도 ConfigMap `app-config` 를, `mock_exam_a/q09` 도 Deployment `api` 를 `web` 에 만들므로 이 두 문제와는 동시에 펼쳐 두지 않는다.

## Task

In namespace `web`, Deployment `api` (image `nginx:1.27`) loads all keys of ConfigMap
`app-config` as environment variables through `envFrom`. The ConfigMap currently contains
`LOG_LEVEL=debug`.

1. Change `LOG_LEVEL` in ConfigMap `app-config` to `info`.
2. Make ConfigMap `app-config` immutable so that its data can no longer be changed.
3. Make the Pods of Deployment `api` use the new value without deleting the Deployment,
   and verify with `kubectl exec` that `LOG_LEVEL=info` is set in a running Pod.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_priorityclass_derived_value/question.md) · [q07 →](../q07_cronjob_manual_trigger/question.md)
