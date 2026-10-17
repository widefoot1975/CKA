# q05 — Rolling update, pause and roll back a Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q05_deployment_rollout_rollback
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 1단계에서 Deployment 를 직접 만드는 것부터 시작하므로, setup 은 이전 흔적(`apps` 네임스페이스)을 지우고
nginx 이미지를 받을 수 있는지만 확인한다. 설정 직후 `apps` 는 없다. 문제 풀이 첫 명령으로 `kubectl create ns apps` 를 실행한다.

## Task

Namespace `apps` serves a web tier that must never drop below its declared capacity
during an update.

1. Create a Deployment `web` in `apps` with 4 replicas of `nginx:1.25`, then set its
   strategy to `RollingUpdate` with `maxSurge: 1` and `maxUnavailable: 0`.
2. Roll it out to `nginx:1.26` and make `bump to 1.26` appear as the change cause in the
   rollout history.
3. Pause the rollout, change the image to `nginx:1.27`, and show that no new ReplicaSet is
   scaled up while paused. Then resume and wait for the rollout to finish.
4. Print the revision history, inspect revision 1, then roll back to the revision running
   `nginx:1.25`.
5. Confirm the running image and that the rollout is complete.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_kubeconfig_certificate_management/question.md) · [q06 →](../q06_configmap_secret_injection/question.md)
