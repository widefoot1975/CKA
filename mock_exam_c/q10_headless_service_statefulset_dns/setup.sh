#!/usr/bin/env bash
# c10 — Headless Service and StatefulSet pod DNS · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace data 는 c11 · d12 와 같이 쓰므로 namespace 는 지우지 않고 이 문제의 리소스만 지운다
set -euo pipefail

# 0) 이전 실습 흔적 정리 (이 문제가 만드는 것만)
kubectl -n data delete sts db --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n data delete svc db db-rw --ignore-not-found 2>/dev/null || true
kubectl -n data delete pod t v v2 --ignore-not-found 2>/dev/null || true
rm -rf /opt/course/q10

# 1) namespace data 준비 (이미 있으면 그대로 쓴다)
kubectl get ns data >/dev/null 2>&1 || kubectl create ns data

# 2) 3번의 조회는 CoreDNS 가 떠 있어야 한다
kubectl -n kube-system wait pod -l k8s-app=kube-dns --for=condition=Ready --timeout=120s

# 3) 설정 확인: data 에 db / db-rw 가 없어야 한다
kubectl -n data get sts,svc
