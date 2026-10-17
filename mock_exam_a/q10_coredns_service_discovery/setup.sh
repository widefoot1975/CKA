#!/usr/bin/env bash
# a10 — Service discovery with CoreDNS · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — 이 문제가 만드는 리소스만 지운다
#    (mock_exam_b/q10 도 alpha·beta 를 쓰므로 namespace 는 다른 리소스가 없을 때만 지운다)
for ns in alpha beta; do
  kubectl get ns "$ns" >/dev/null 2>&1 || continue
  kubectl -n "$ns" delete deploy/web svc/web pod/no-dns pod/dns --ignore-not-found --wait=true
  if [ -z "$(kubectl -n "$ns" get deploy,sts,ds,svc,pod,job,cronjob -o name 2>/dev/null)" ]; then
    kubectl delete ns "$ns" --wait=true
  else
    echo "namespace $ns 에 다른 문제의 리소스가 남아 있어 namespace 는 지우지 않음"
  fi
done

# 1) 노드가 nginx 와 DNS 디버그 이미지를 받을 수 있는지 미리 확인 (오프라인 실습 환경 대비)
kubectl run img-check --image=nginx:1.27 --restart=Never --rm -i --pod-running-timeout=2m -- nginx -v || \
  echo "nginx 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"
kubectl run img-check-dns --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 \
  --restart=Never --rm -i --pod-running-timeout=2m -- true || \
  echo "jessie-dnsutils 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"

# 2) 시작 상태 확인: CoreDNS 가 Ready 이고 alpha·beta 에 web 이 없음
kubectl -n kube-system rollout status deploy coredns --timeout=120s
for ns in alpha beta; do
  kubectl -n "$ns" get deploy,svc web 2>/dev/null || echo "$ns/web 없음 (정상)"
done
