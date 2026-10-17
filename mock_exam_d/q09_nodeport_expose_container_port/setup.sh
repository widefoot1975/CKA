#!/usr/bin/env bash
# d09 — NodePort Service for a container port · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns spline --ignore-not-found --wait=true
kubectl create ns spline

# 1) Deployment front-end: nginx:1.27, 컨테이너 이름 nginx, ports 선언 없음 (--port 를 주지 않는다)
kubectl -n spline create deploy front-end --image=nginx:1.27 --replicas=2
kubectl -n spline rollout status deploy front-end --timeout=120s

# 2) nodePort 30080 을 다른 Service 가 쓰고 있지 않은지 확인 (쓰고 있으면 문제 2단계가 실패한다)
kubectl get svc -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name} {.spec.ports[*].nodePort}{"\n"}{end}' \
  | grep -w 30080 && echo "nodePort 30080 사용 중 — 위 Service 를 먼저 정리할 것" || echo "nodePort 30080 비어 있음 (정상)"

# 3) 시작 상태 확인: 컨테이너 ports 가 비어 있고 Service 가 없어야 함
kubectl -n spline get deploy front-end -o jsonpath='{.spec.template.spec.containers[0].name} ports={.spec.template.spec.containers[0].ports}{"\n"}'
kubectl -n spline get svc
