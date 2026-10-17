# q05 — Rolling update, pause and roll back a Deployment

| Item | Value |
|---|---|
| Exam | mock_exam_a |
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
# 0) 이전 실습 흔적 정리 — 이 문제는 namespace apps 부터 직접 만든다
kubectl delete ns apps --ignore-not-found --wait=true

# 1) 노드가 nginx 이미지를 받을 수 있는지 미리 확인 (오프라인 실습 환경 대비)
kubectl run img-check --image=nginx:1.27 --restart=Never --rm -i --pod-running-timeout=2m -- nginx -v || \
  echo "nginx 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"

# 2) 시작 상태 확인: namespace apps 가 없어야 함
kubectl get ns apps 2>/dev/null || echo "namespace apps 없음 (정상)"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 1단계에서 Deployment 를 직접 만드는 것부터 시작하므로, setup 은 이전 흔적(`apps` 네임스페이스)을 지우고
nginx 이미지를 받을 수 있는지만 확인한다. 설정 직후 `apps` 는 없다. 문제 풀이 첫 명령으로 `kubectl create ns apps` 를 실행한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns apps --ignore-not-found
```

</details>

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

---

Solution → **[solution.md](solution.md)**
