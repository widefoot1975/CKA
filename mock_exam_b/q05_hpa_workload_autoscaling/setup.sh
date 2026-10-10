#!/usr/bin/env bash
# b05 — HPA workload autoscaling · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: namespace web 을 새로 만든다 (mock_exam_f/q06 도 web 을 쓰므로 함께 풀지 말 것)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns web --ignore-not-found --wait=true
rm -rf /opt/q05

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + Deployment frontend (nginx:1.27, 1 replica, resources 없음 → 컨테이너 이름 nginx)
kubectl create ns web
kubectl -n web create deploy frontend --image=nginx:1.27 --replicas=1
kubectl -n web rollout status deploy frontend

# 3) 답안 파일 디렉터리
mkdir -p /opt/q05

# 4) 설정 확인: resources 가 비어 있고 HPA 는 없음
kubectl -n web get deploy frontend \
  -o jsonpath='{.spec.template.spec.containers[0].name}{" resources="}{.spec.template.spec.containers[0].resources}{"\n"}'
kubectl -n web get hpa
