#!/usr/bin/env bash
# d06 — ConfigMap as env var and file · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (ConfigMap app-settings, 파드 settings-demo 도 함께 지워진다)
kubectl delete ns cfg --ignore-not-found --wait=true

# 1) 빈 namespace cfg 만 만든다 — ConfigMap 과 파드는 문제에서 직접 만든다
kubectl create ns cfg

# 2) 시작 상태 확인: kube-root-ca.crt 외에 ConfigMap 이 없고 파드도 없어야 함
kubectl -n cfg get cm,pod
