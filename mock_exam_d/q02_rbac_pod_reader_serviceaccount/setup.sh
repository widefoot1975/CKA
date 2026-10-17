#!/usr/bin/env bash
# d02 — Read-only pod access for a ServiceAccount · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (ServiceAccount·Role·RoleBinding 도 네임스페이스와 함께 지워진다)
kubectl delete ns apps --ignore-not-found --wait=true
kubectl create ns apps

# 1) 로그를 읽어 볼 파드 하나: 5초마다 한 줄씩 출력
kubectl -n apps run logger --image=busybox:1.36 -- sh -c 'i=0; while true; do echo "tick $i"; i=$((i+1)); sleep 5; done'
kubectl -n apps wait pod logger --for=condition=Ready --timeout=120s

# 2) 시작 상태 확인: ServiceAccount 는 default 만, Role·RoleBinding 은 없어야 한다
kubectl -n apps get sa,role,rolebinding,pods
