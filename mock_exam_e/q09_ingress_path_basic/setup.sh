#!/usr/bin/env bash
# e09 — Publish a Service with an Ingress · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 1) Ingress 컨트롤러: F5 NGINX Ingress Controller v5.6.3 (IngressClass nginx, Service 는 NodePort)
#    은퇴한 ingress-nginx 가 아니라 nginx/kubernetes-ingress 다. 이미 설치돼 있으면 그대로 넘어간다.
kubectl apply --server-side -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ns-and-sa.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/rbac/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/nginx-config.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/common/ingress-class.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/deployment/nginx-ingress.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.6.3/deployments/service/nodeport.yaml
kubectl -n nginx-ingress rollout status deploy nginx-ingress --timeout=180s

# 2) 이전 실습 흔적 정리 후 namespace echo
kubectl delete ns echo --ignore-not-found --wait=true
kubectl create ns echo

# 3) 백엔드: 어떤 경로든 200 과 "echo" 를 돌려주는 http-echo (컨테이너 포트 5678) → Service echo-svc:8080
kubectl -n echo create deploy echo --image=hashicorp/http-echo:1.0 -- /http-echo -text=echo
kubectl -n echo expose deploy echo --name=echo-svc --port=8080 --target-port=5678
kubectl -n echo rollout status deploy echo

# 4) 시작 상태 확인: IngressClass 가 하나 있고, echo 에는 Ingress 가 없음
kubectl get ingressclass
kubectl -n echo get deploy,svc,ingress
