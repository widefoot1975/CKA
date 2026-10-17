#!/usr/bin/env bash
# c07 — Run work with a Job and a CronJob · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace batch 는 mock_exam_d/q17 도 쓰므로 namespace 를 통째로 지우지 않고 이 문제의 리소스만 지운다.
set -euo pipefail

# 0) 이전 실습 흔적 정리 (CronJob report 를 지우면 그 아래 Job 도 함께 지워진다)
kubectl -n batch delete cronjob report --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n batch delete job migrate broken report-manual --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true

# 1) 작업할 namespace (없을 때만 만들고, 이 문제가 만든 것이라는 표시를 붙인다)
if ! kubectl get ns batch >/dev/null 2>&1; then
  kubectl create ns batch
  kubectl label ns batch cka-practice=c07
fi

# 2) 설정 확인: batch 에 이 문제의 Job·CronJob 이 없어야 함
kubectl get ns batch
kubectl -n batch get cronjob,job
