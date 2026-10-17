#!/usr/bin/env bash
# b09 — NetworkPolicy ingress + egress · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (namespace 를 지우면 만들었던 NetworkPolicy 도 함께 지워진다)
kubectl delete ns payments frontend scanner --ignore-not-found --wait=true
kubectl create ns payments
kubectl create ns frontend
kubectl create ns scanner

# 1) 모든 파드에 netshoot 이미지 사용 (curl · nc · nslookup 이 다 들어 있음)
IMG=nicolaka/netshoot:v0.13

# payments: api 는 8080 HTTP, db 는 5432 TCP. --expose 로 같은 이름의 Service 도 만든다
kubectl -n payments run api --image=$IMG --labels=app=api --port=8080 --expose -- python3 -m http.server 8080
kubectl -n payments run db  --image=$IMG --labels=app=db  --port=5432 --expose -- nc -lk 5432

# frontend 의 web 과 scanner 의 probe 는 라벨이 같다 (app=web)
kubectl -n frontend run web  --image=$IMG --labels=app=web -- sleep 3600
kubectl -n scanner  run probe --image=$IMG --labels=app=web -- sleep 3600

kubectl -n payments wait pod --all --for=condition=Ready --timeout=180s
kubectl -n frontend wait pod web   --for=condition=Ready --timeout=180s
kubectl -n scanner  wait pod probe --for=condition=Ready --timeout=180s

# 2) 시작 상태 확인: 정책이 없어서 지금은 모두 닿는다
kubectl -n payments get pods,svc --show-labels
kubectl get ns frontend scanner --show-labels
kubectl -n payments get netpol
kubectl -n scanner exec probe -- curl -s -o /dev/null -w 'probe → api:8080 HTTP %{http_code}\n' --max-time 3 api.payments:8080
kubectl -n payments exec api -- nc -zv -w 3 db 5432
