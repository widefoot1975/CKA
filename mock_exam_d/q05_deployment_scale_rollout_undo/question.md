# q05 — Scale, update and roll back a Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_d |
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
# 0) 이전 실습 흔적 정리 (리비전 기록까지 지우려면 네임스페이스째 새로 만든다)
kubectl delete ns shop --ignore-not-found --wait=true
kubectl create ns shop

# 1) Deployment web: nginx:1.27, 2 replicas (컨테이너 이름은 이미지에서 딴 nginx)
kubectl -n shop create deploy web --image=nginx:1.27 --replicas=2
kubectl -n shop rollout status deploy web --timeout=120s

# 2) 시작 상태 확인: 2/2 Ready, 이미지 nginx:1.27, 리비전 1개
kubectl -n shop get deploy web -o wide
kubectl -n shop rollout history deploy web
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `shop` 에는 Deployment `web`(컨테이너 `nginx`, 이미지 `nginx:1.27`, 레플리카 2) 하나만 있고
`rollout history` 에는 리비전 1 하나만 보인다. 변경 사유 어노테이션은 아직 없다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns shop --ignore-not-found
```

</details>

## Task

Namespace `shop` contains Deployment `web` (image `nginx:1.27`, 2 replicas).

1. Scale `web` to 4 replicas.
2. Update the image of its container to `nginx:1.28` and record the change cause
   `upgrade to 1.28` on the Deployment so that it appears in the rollout history.
3. Roll `web` back to the previous revision.
4. Confirm that `web` runs image `nginx:1.27` again with 4 ready replicas.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
