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

## PreIns

```
# 0) 이전 실습 흔적 정리 (다시 풀 때를 대비해 여러 번 실행해도 안전함)
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
value: 500000                 # 정답 기준: 사용자 정의 클래스 중 최댓값 → high-priority = 499999
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

# 설정확인
kubectl get pc --sort-by=.value
kubectl -n priority get pods -o custom-columns=NAME:.metadata.name,CLASS:.spec.priorityClassName,PRIORITY:.spec.priority
```

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
