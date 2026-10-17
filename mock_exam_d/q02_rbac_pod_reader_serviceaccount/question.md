# q02 — Read-only pod access for a ServiceAccount

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q02_rbac_pod_reader_serviceaccount
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `apps` 에는 5초마다 `tick N` 을 찍는 파드 `logger` 와 기본 ServiceAccount `default` 만 있다. `monitor`, `pod-reader`, `monitor-pod-reader` 는 없다.
`logger` 는 문제 4번에서 로그 권한을 확인할 때 쓴다(`kubectl -n apps logs logger --as=system:serviceaccount:apps:monitor`).

## Task

A monitoring tool in namespace `apps` will run under its own ServiceAccount. It must be able to
read pods and their logs, and nothing else.

1. Create ServiceAccount `monitor` in namespace `apps`.
2. Create Role `pod-reader` in `apps` that allows the verbs `get`, `list` and `watch` on the
   resources `pods` and `pods/log`.
3. Bind the Role to the ServiceAccount with RoleBinding `monitor-pod-reader` in `apps`.
4. Using `kubectl auth can-i` while impersonating the ServiceAccount, confirm that it can list
   pods and read pod logs in `apps`, but cannot delete pods.

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

[↑ 문항 목록](../README.md) · [← q01](../q01_helm_install_pinned_chart/question.md) · [q03 →](../q03_crd_explore_explain/question.md)
