# q05 — Configure workload autoscaling with an HPA

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q05_hpa_workload_autoscaling
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `frontend` 의 컨테이너 이름은 `nginx`, resources 는 `{}` 이고 HPA 는 없다. metrics-server 가 값을 모으기까지 1분 정도 걸릴 수 있다.
namespace `web` 은 A06·A09·D08·F06 도 쓰므로 setup·cleanup 은 이 문제의 오브젝트(`frontend`, `frontend-hpa`)만 지우고, namespace 는 이 setup 이 만들었고 비어 있을 때만 지운다.
`mock_exam_d/q08` 도 `web` 에 Deployment `frontend` 를 만들므로 두 문제를 동시에 펼쳐 두지 않는다. `cleanup.sh` 는 metrics-server 를 남겨 둔다.

## Task

Namespace `web` contains deployment `frontend` (image `nginx:1.27`, 1 replica) with no
resource fields set. Its owner reports that an HPA they created shows `<unknown>` for CPU.

1. Give the `frontend` container a CPU request of `100m` and a CPU limit of `200m`,
   without editing a manifest file on disk.
2. Create a HorizontalPodAutoscaler named `frontend-hpa` in `web` using
   `autoscaling/v2`, targeting the `frontend` deployment, `minReplicas: 2`,
   `maxReplicas: 8`, scaling on average CPU **utilization** of `60%`. When scaling down,
   it must use a stabilization window of `30` seconds.
3. Confirm the HPA reports a real percentage in the `TARGETS` column rather than
   `<unknown>`, and that replicas settled at 2.
4. Write to `/opt/q05/answer.txt` the two prerequisites that must hold before an
   `averageUtilization` metric can be computed at all.

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

[↑ 문항 목록](../README.md) · [← q04](../q04_crictl_container_runtime/question.md) · [q06 →](../q06_resourcequota_limitrange/question.md)
