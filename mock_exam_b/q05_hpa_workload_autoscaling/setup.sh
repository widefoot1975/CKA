#!/usr/bin/env bash
# b05 — HPA workload autoscaling · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace web 은 mock_exam_a/q06·q09, mock_exam_d/q08, mock_exam_f/q06 도 쓰므로 namespace 는 지우지 않고 이 문제의 오브젝트만 정리한다.
# 주의: mock_exam_d/q08 도 web 에 Deployment frontend 를 만들므로 함께 풀지 말 것
set -euo pipefail

# 0) 이전 실습 흔적 정리 (이 문제가 만드는 오브젝트만)
kubectl -n web delete hpa frontend-hpa --ignore-not-found 2>/dev/null || true
kubectl -n web delete deploy frontend --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
rm -rf /opt/q05

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns web >/dev/null 2>&1; then
  kubectl create ns web
  kubectl label ns web cka-lab-b05=created --overwrite
fi
#    Deployment frontend (nginx:1.27, 1 replica, resources 없음 → 컨테이너 이름 nginx)
kubectl -n web create deploy frontend --image=nginx:1.27 --replicas=1
kubectl -n web rollout status deploy frontend

# 3) 답안 파일 디렉터리
mkdir -p /opt/q05

# 4) 설정 확인: resources 가 비어 있고 HPA 는 없음
kubectl -n web get deploy frontend \
  -o jsonpath='{.spec.template.spec.containers[0].name}{" resources="}{.spec.template.spec.containers[0].resources}{"\n"}'
kubectl -n web get hpa
