#!/usr/bin/env bash
# e05 — Autoscale a Deployment with an HPA · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns autoscale --ignore-not-found --wait=true

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + Deployment apache-web (httpd:2.4, CPU request 100m)
kubectl create ns autoscale
kubectl -n autoscale create deploy apache-web --image=httpd:2.4
kubectl -n autoscale set resources deploy apache-web --requests=cpu=100m
kubectl -n autoscale rollout status deploy apache-web

# 3) 설정 확인 (metrics-server 가 값을 모으기까지 1분 정도 걸릴 수 있음)
kubectl get pods -n kube-system -l k8s-app=metrics-server
kubectl -n autoscale get deploy apache-web \
  -o jsonpath='{.spec.template.spec.containers[0].resources}{"\n"}'
