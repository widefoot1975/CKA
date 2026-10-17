#!/usr/bin/env bash
# c07 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace batch 는 mock_exam_d/q17 도 쓰므로, setup.sh 가 만든 namespace 이고 다른 리소스가 없을 때만 지운다.
set -euo pipefail

# CronJob 을 지우면 스케줄 실행 Job 과 --from=cronjob/report 로 만든 Job 도 함께 지워진다
kubectl -n batch delete cronjob report --ignore-not-found --cascade=foreground --wait=true
kubectl -n batch delete job migrate broken report-manual --ignore-not-found --cascade=foreground --wait=true

if [ "$(kubectl get ns batch -o jsonpath='{.metadata.labels.cka-practice}' 2>/dev/null || true)" = "c07" ] \
   && [ -z "$(kubectl -n batch get pods,jobs,cronjobs,deploy,sts,ds -o name 2>/dev/null)" ]; then
  kubectl delete ns batch --ignore-not-found
fi
