#!/usr/bin/env bash
# a06 — ConfigMap and Secret injection · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: namespace web 은 mock_exam_a/q09, mock_exam_b/q05, mock_exam_f/q06 도 쓴다.
#       특히 f06 도 ConfigMap app-config 를 만들므로 함께 풀지 말 것.
set -euo pipefail

# 0) 이전 실습 흔적 정리 — 이 문제가 만드는 오브젝트만 지운다 (namespace 는 남김)
if kubectl get ns web >/dev/null 2>&1; then
  kubectl -n web delete pod web-app --ignore-not-found --wait=true
  kubectl -n web delete configmap app-config app-files --ignore-not-found
  kubectl -n web delete secret db-cred --ignore-not-found
fi

# 1) namespace web 준비 (문제는 web 이 이미 있다고 가정한다)
kubectl create ns web --dry-run=client -o yaml | kubectl apply -f -

# 2) 노드가 nginx 이미지를 받을 수 있는지 미리 확인 (오프라인 실습 환경 대비)
kubectl run img-check --image=nginx:1.27 --restart=Never --rm -i --pod-running-timeout=2m -- nginx -v || \
  echo "nginx 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"

# 3) 시작 상태 확인: web-app / app-config / app-files / db-cred 가 없어야 함
kubectl -n web get pod,configmap,secret
