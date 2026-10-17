#!/usr/bin/env bash
# b07 — Pod priority and preemption · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: PriorityClass 는 클러스터 범위다. 다른 문제의 클래스는 건드리지 않는다
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns sched --ignore-not-found --wait=true
kubectl delete priorityclass critical-priority low-priority queue-jumper --ignore-not-found
rm -rf /opt/q07

# 1) 다른 팀이 만들어 둔 사용자 정의 PriorityClass (모두 10000 초과, globalDefault 없음)
cat <<'YAML' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: team-batch
value: 20000
globalDefault: false
description: "Team batch jobs"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: ml-training
value: 300000
globalDefault: false
description: "ML training workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: ops-urgent
value: 750000
globalDefault: false
description: "Ops on-call tooling"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: zz-observer
value: 600000
preemptionPolicy: Never
globalDefault: false
description: "Monitoring, never preempts"
YAML

# 2) 문제용 namespace (비어 있음)
kubectl create ns sched

# 3) 답안 파일 디렉터리
mkdir -p /opt/q07

# 4) 설정 확인
kubectl get pc --sort-by=.value
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu,TAINTS:.spec.taints[*].effect
