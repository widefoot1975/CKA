# q05 — Create a PriorityClass relative to existing ones

| Item | Value |
|---|---|
| Exam | mock_exam_f |
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
# 0) 이전 실습 흔적 정리
kubectl delete priorityclass high-priority --ignore-not-found
kubectl delete ns priority --ignore-not-found --wait=true

# 1) 사용자 정의 PriorityClass 여러 개 (함정 포함)
cat <<'EOF' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: batch-low
value: 1000
globalDefault: false
description: "Low priority for batch jobs"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: default-workload
value: 10000
globalDefault: true          # 함정: global default지만 최댓값은 아님
description: "Cluster-wide default for pods without a class"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: team-standard
value: 250000
globalDefault: false
description: "Standard team workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: team-critical
value: 500000
globalDefault: false
description: "Most important user workload"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: zz-preempt-never
value: 400000
preemptionPolicy: Never       # 함정: 이름순으로는 마지막이지만 최댓값은 아님
globalDefault: false
description: "High but non-preempting"
EOF

# 2) 네임스페이스와 Deployment (처음에는 priorityClassName 없음)
kubectl create ns priority
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-logger
  namespace: priority
spec:
  replicas: 2
  selector:
    matchLabels:
      app: busybox-logger
  template:
    metadata:
      labels:
        app: busybox-logger
    spec:
      containers:
      - name: logger
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo \"$(date) logging\"; sleep 5; done"]
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
EOF

kubectl -n priority rollout status deploy busybox-logger

# 3) 설정 확인
kubectl get pc --sort-by=.value
kubectl -n priority get pods \
  -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 파드는 `default-workload` / `10000` 으로 보인다(global default 클래스가 자동 적용됨).
`default-workload` 는 globalDefault 라서 클러스터의 다른 새 파드에도 붙으므로, 실습이 끝나면 꼭 정리한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns priority --ignore-not-found
kubectl delete priorityclass high-priority batch-low default-workload \
  team-standard team-critical zz-preempt-never --ignore-not-found
```

</details>

## Task

Deployment `busybox-logger` in namespace `priority` needs a high priority, just below the
most important existing user workload. Several user-defined PriorityClasses already exist
in the cluster.

1. Find the highest `value` among the existing user-defined PriorityClasses (ignore the
   built-in `system-*` classes). Create PriorityClass `high-priority` with a value exactly
   one less than that. It must not be the global default.
2. Patch Deployment `busybox-logger` in namespace `priority` so that its Pods use
   PriorityClass `high-priority`.
3. Confirm that the Deployment's new Pods have `spec.priority` equal to the value of
   `high-priority`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
