# q07 — Dedicate a node with a taint and a toleration

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
# 0) 노드 worker02 가 있는지 확인
kubectl get node worker02

# 1) 이전 실습 흔적 정리 (파드, taint, 라벨)
kubectl -n default delete pod gpu-job plain --ignore-not-found --wait=true
kubectl taint node worker02 dedicated- 2>/dev/null || true
kubectl label node worker02 accelerator- 2>/dev/null || true

# 2) 설정 확인: worker02 에 taint 와 accelerator 라벨이 없어야 함
kubectl describe node worker02 | grep -A2 Taints
kubectl get nodes -L accelerator
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `worker02` 에는 taint 와 `accelerator` 라벨이 없다. 문제 풀이에서 직접 붙인다.
taint 를 그대로 두면 다른 문제의 파드가 `worker02` 에 올라가지 못하므로 실습이 끝나면 꼭 정리한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n default delete pod gpu-job plain --ignore-not-found
kubectl taint node worker02 dedicated- 2>/dev/null || true
kubectl label node worker02 accelerator- 2>/dev/null || true
```

</details>

## Task

Node `worker02` is to be reserved for GPU workloads: other pods must stay off it, and GPU pods
must land on it.

1. Taint node `worker02` with `dedicated=gpu:NoSchedule` and add the label `accelerator=gpu`
   to it.
2. Create pod `gpu-job` in namespace `default` (image `nginx:1.27`) that tolerates this taint
   and has the `nodeSelector` `accelerator: gpu`. Confirm it is running on `worker02`.
3. Create pod `plain` in `default` (image `nginx:1.27`) with the same `nodeSelector` but without
   the toleration. Confirm it stays `Pending` and that its scheduling event mentions the
   untolerated taint.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
