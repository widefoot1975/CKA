#!/usr/bin/env bash
# f07 — Schedule and trigger a CronJob · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (CronJob cleanup, Job cleanup-manual, 로그 파일)
kubectl delete ns ops --ignore-not-found --wait=true
rm -rf /opt/course/f07

# 1) 문제에서 "이미 있다"고 가정하는 namespace
kubectl create ns ops

# 2) 로그 파일을 쓸 디렉터리
mkdir -p /opt/course/f07

# 3) 설정 확인: ops 는 비어 있어야 함
kubectl get ns ops
kubectl -n ops get cronjob,job
