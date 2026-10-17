#!/usr/bin/env bash
# f12 — Projected volume · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace proj 는 D10 과 같이 쓰므로 namespace 를 통째로 지우지 않고 이 문제의 리소스만 정리한다
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl create ns proj --dry-run=client -o yaml | kubectl apply -f -
kubectl -n proj delete pod projected-demo --ignore-not-found --wait=true
kubectl -n proj delete secret db-cred --ignore-not-found
kubectl -n proj delete cm app-cfg --ignore-not-found

# 1) Secret db-cred (키 password) 와 ConfigMap app-cfg (키 app.conf)
kubectl -n proj create secret generic db-cred --from-literal=password='S3cr3t-pw'
kubectl -n proj create cm app-cfg --from-literal=app.conf='log_level=info'

# 2) 시작 상태 확인: Secret·ConfigMap 은 있고 파드 projected-demo 는 없음
kubectl -n proj get secret db-cred
kubectl -n proj get cm app-cfg -o jsonpath='{.data.app\.conf}{"\n"}'
kubectl -n proj get pod projected-demo --ignore-not-found
