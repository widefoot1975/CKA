#!/usr/bin/env bash
# a08 — Service types and endpoints · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — 이 문제는 namespace shop 부터 직접 만든다
#    (D05 도 shop 을 쓰므로 D05 실습 상태도 함께 지워진다)
kubectl delete ns shop --ignore-not-found --wait=true

# 1) nodePort 31080 을 다른 Service 가 쓰고 있지 않은지 확인 (쓰고 있으면 3단계가 실패한다)
kubectl get svc -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name} {.spec.ports[*].nodePort}{"\n"}{end}' \
  | grep -w 31080 && echo "nodePort 31080 사용 중 — 위 Service 를 먼저 정리할 것" || echo "nodePort 31080 비어 있음 (정상)"

# 2) LoadBalancer 구현체(MetalLB 등)가 있는지 확인 — 없으면 api-lb 의 EXTERNAL-IP 는 <pending> 이 정상
kubectl get pods -A 2>/dev/null | grep -i metallb || echo "LoadBalancer 구현체 없음 → EXTERNAL-IP <pending> 예상"

# 3) 시작 상태 확인: namespace shop 이 없어야 함
kubectl get ns shop 2>/dev/null || echo "namespace shop 없음 (정상)"
