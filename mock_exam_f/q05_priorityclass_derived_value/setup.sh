#!/usr/bin/env bash
# q05 — Create a PriorityClass relative to existing ones · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

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
