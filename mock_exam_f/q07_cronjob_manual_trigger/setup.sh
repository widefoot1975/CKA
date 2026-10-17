#!/usr/bin/env bash
# f07 — Schedule and trigger a CronJob · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace ops 는 mock_exam_a/q11·q12 도 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다.
set -euo pipefail

# 0) 이전 실습 흔적 정리 (CronJob cleanup, Job cleanup-manual, 로그 파일)
kubectl -n ops delete cronjob cleanup --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n ops delete job cleanup-manual --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
rm -rf /opt/course/f07

# 1) 문제에서 "이미 있다"고 가정하는 namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다
if ! kubectl get ns ops >/dev/null 2>&1; then
  kubectl create ns ops
  kubectl label ns ops cka-lab-f07=created --overwrite
fi

# 2) 로그 파일을 쓸 디렉터리
mkdir -p /opt/course/f07

# 3) 설정 확인: ops 에 CronJob·Job 이 없어야 함
kubectl get ns ops
kubectl -n ops get cronjob,job
