#!/usr/bin/env bash
# b10 — Pod connectivity across namespaces · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — 이 문제가 만드는 리소스만 지운다
#    (mock_exam_a/q10 도 alpha·beta 를 쓰므로 namespace 는 다른 리소스가 없을 때만 지운다)
kubectl -n alpha delete deploy/alpha-web svc/alpha-web --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n beta  delete pod/probe --ignore-not-found --wait=true 2>/dev/null || true
for ns in alpha beta; do
  kubectl get ns "$ns" >/dev/null 2>&1 || continue
  if [ -z "$(kubectl -n "$ns" get deploy,sts,ds,svc,pod,job,cronjob -o name 2>/dev/null)" ]; then
    kubectl delete ns "$ns" --wait=true
  else
    echo "namespace $ns 에 다른 문제의 리소스가 남아 있어 namespace 는 지우지 않음"
  fi
done
rm -rf /opt/q10

# 1) 답안 파일 디렉터리 (namespace·Deployment·Service·파드는 문제에서 직접 만든다)
mkdir -p /opt/q10

# 2) 설정 확인: alpha-web 과 probe 가 없어야 함
kubectl -n alpha get deploy,svc alpha-web 2>/dev/null || echo "alpha/alpha-web 없음 (정상)"
kubectl -n beta  get pod probe 2>/dev/null           || echo "beta/probe 없음 (정상)"
ls -ld /opt/q10
