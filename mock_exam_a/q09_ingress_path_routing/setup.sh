#!/usr/bin/env bash
# a09 — Route traffic with an Ingress · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace web 은 다른 문제(b05, d08, f06)도 쓰므로 통째로 지우지 않고 이 문제의 리소스만 지운다.
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

# 2) namespace web 준비 — 없으면 만들고, 이전 실습에서 만든 이 문제의 리소스만 지운다
kubectl create ns web --dry-run=client -o yaml | kubectl apply -f -
kubectl -n web delete ingress shop-ingress --ignore-not-found
kubectl -n web delete svc site-svc api-svc --ignore-not-found
kubectl -n web delete deploy site api --ignore-not-found --cascade=foreground --wait=true
kubectl -n web delete pod img-check --ignore-not-found --wait=true

# 3) 노드가 echoserver 이미지를 받을 수 있는지 미리 확인 (오프라인 실습 환경 대비)
kubectl -n web run img-check --image=registry.k8s.io/e2e-test-images/echoserver:2.5 --restart=Never
kubectl -n web wait --for=condition=Ready pod/img-check --timeout=120s || \
  echo "echoserver 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"
kubectl -n web delete pod img-check --ignore-not-found --wait=true

# 4) 시작 상태 확인: IngressClass 가 하나 있고, web 에는 site / api / shop-ingress 가 없음
kubectl get ingressclass
kubectl -n web get deploy,svc,ingress
