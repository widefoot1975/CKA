#!/usr/bin/env bash
# c06 — Probes and a PodDisruptionBudget · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 필요: 스케줄 가능한 워커 노드 2개 이상 (6번 drain 이 다른 노드로 파드를 옮겨야 끝난다)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — shop 은 다른 문제도 쓰는 namespace 라 이 문제의 리소스만 지운다
kubectl -n shop delete deploy api --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n shop delete svc api --ignore-not-found 2>/dev/null || true
kubectl -n shop delete pdb api-pdb --ignore-not-found 2>/dev/null || true

# 1) 지금 이미 cordon 된 노드를 적어 둔다 (cleanup.sh 가 6번에서 drain 한 노드만 uncordon 하도록)
kubectl get nodes -o jsonpath='{range .items[?(@.spec.unschedulable==true)]}{.metadata.name}{"\n"}{end}' \
  > /tmp/cka-c06-precordoned.txt

# 2) namespace + Deployment api (프로브 없음) + Service api
kubectl create ns shop --dry-run=client -o yaml | kubectl apply -f -
kubectl -n shop create deployment api --image=nginx:1.27 --replicas=3 --port=80
kubectl -n shop expose deployment api --port=80 --target-port=80
kubectl -n shop rollout status deploy api --timeout=180s

# 3) 설정 확인: 파드 3개 Running, 어느 노드에 몇 개 있는지
kubectl -n shop get deploy,svc,pdb
kubectl -n shop get pods -l app=api -o wide
