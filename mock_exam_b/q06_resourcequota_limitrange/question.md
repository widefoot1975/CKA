# q06 — Constrain a namespace with ResourceQuota and LimitRange

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (namespace team-a 는 문제에서 직접 만든다)
kubectl delete ns team-a --ignore-not-found --wait=true
rm -rf /opt/q06

# 1) 답안 파일 디렉터리
mkdir -p /opt/q06

# 2) 설정 확인: team-a 가 없어야 함
kubectl get ns team-a 2>/dev/null || echo "namespace team-a 없음 (정상)"
ls -ld /opt/q06
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

namespace `team-a` 는 문제 1번에서 직접 만들어야 하므로 setup 은 지우기만 하고, 답안 디렉터리 `/opt/q06/` 만 만든다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns team-a --ignore-not-found
rm -rf /opt/q06
```

</details>

## Task

Namespace `team-a` must be capped, and its users must not have to write resource fields
by hand.

1. Create namespace `team-a` and a ResourceQuota named `team-a-quota` with
   `requests.cpu: "1"`, `requests.memory: 1Gi`, `limits.cpu: "2"`,
   `limits.memory: 2Gi`, `pods: "10"`, `configmaps: "5"`.
2. Try to create a pod named `probe` with image `nginx:1.27` and **no** resource fields.
   Write the exact rejection message to `/opt/q06/rejected.txt`.
3. Create a LimitRange named `team-a-defaults` for `Container` with
   `defaultRequest` cpu `100m` / memory `128Mi`, `default` cpu `200m` /
   memory `256Mi`, and `max` cpu `500m`.
4. Create `probe` again, still with no resource fields, and show the values it was given.
5. Show the quota's used-versus-hard figures and confirm `requests.cpu` used is `100m`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
