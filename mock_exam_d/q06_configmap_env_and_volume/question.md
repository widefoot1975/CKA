# q06 — Inject a ConfigMap as an env var and a file

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
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q06_configmap_env_and_volume
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `cfg` 는 비어 있다(자동으로 생기는 ConfigMap `kube-root-ca.crt` 만 있음).
`app-settings` 와 `settings-demo` 는 문제를 풀면서 만든다.

## Task

Namespace `cfg` exists. An application needs one setting as an environment variable and all
settings as files.

1. Create ConfigMap `app-settings` in `cfg` with the keys `MODE=prod` and `COLOR=blue`.
2. Create pod `settings-demo` in `cfg` (image `busybox:1.36`, command `sleep 3600`) that
   - receives the value of key `MODE` as environment variable `APP_MODE`, and
   - mounts the whole ConfigMap as a volume at `/etc/settings`.
3. Verify inside the pod that `APP_MODE` is `prod` and that the file `/etc/settings/COLOR`
   contains `blue`.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_deployment_scale_rollout_undo/question.md) · [q07 →](../q07_taint_toleration_dedicated_node/question.md)
