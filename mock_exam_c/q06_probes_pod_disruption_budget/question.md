# q06 — Probes and a PodDisruptionBudget

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
A08·A15 도 `shop` 에 Deployment `api` 를 만들므로 세 문제를 동시에 펼쳐 두지 않는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q06_probes_pod_disruption_budget
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `shop` 에 프로브가 없는 Deployment `api`(파드 3개 `1/1 Running`)와 Service `api` 가 있고, PDB 는 아직 없다.
스케줄 가능한 워커 노드가 2개 이상이어야 6번 drain 이 끝난다. 파드가 노드마다 1개씩 퍼졌다면 6번은 `api` 파드가 가장 많은 노드로 한다.
`shop` 은 다른 문제도 쓰는 namespace 라 setup·cleanup 은 이 문제의 리소스(`api`, `api-pdb`)만 지우고, cleanup 은 namespace 가 비었을 때만 지운다.

## Task

Namespace `shop` contains Deployment `api` with 3 replicas of `nginx:1.27`, labelled
`app=api`, serving on port 80.

1. Add a startup probe: HTTP GET `/` on port 80, allowed up to 60 seconds to come up,
   probing every 5 seconds.
2. Add a readiness probe: HTTP GET `/healthz` on port 80, every 5 seconds,
   `failureThreshold: 2`.
3. Add a liveness probe: TCP socket on port 80, `periodSeconds: 10`,
   `failureThreshold: 3`.
4. Create a PodDisruptionBudget `api-pdb` for `app=api` that keeps at least 2 pods
   available.
5. `/healthz` does not exist on the nginx image, so readiness will fail. Show what happens
   to the rollout and to the Service `api` endpoints, then make readiness pass by pointing
   the probe at a path that exists and let the rollout finish.
6. Attempt `kubectl drain` on the node holding two `api` pods and report what the PDB does.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_statefulset_daemonset_selfheal/question.md) · [q07 →](../q07_job_cronjob/question.md)
