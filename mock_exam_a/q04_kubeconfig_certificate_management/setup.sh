#!/usr/bin/env bash
# a04 — Create a kubeconfig for a certificate-based user · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 root 로 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — CSR, RBAC, /root 의 jane 파일
#    namespace dev 는 q14 도 쓰므로 지우지 않는다
kubectl delete csr jane --ignore-not-found
kubectl -n dev delete rolebinding jane-pod-reader --ignore-not-found 2>/dev/null || true
kubectl -n dev delete role pod-reader --ignore-not-found 2>/dev/null || true
rm -f /root/jane.key /root/jane.csr /root/jane.crt /root/jane.kubeconfig /root/jane-csr.yaml /root/k8s-c1-ca.crt

# 1) 대상 namespace dev 와, 목록에 보일 파드 하나
kubectl create ns dev --dry-run=client -o yaml | kubectl apply -f -
kubectl -n dev run a04-web --image=nginx:1.27 --labels=app=a04-web \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n dev wait --for=condition=Ready pod/a04-web --timeout=120s || \
  echo "a04-web 이 아직 Ready 가 아님 — 목록 확인에는 지장 없음"

# 2) 도구 확인: openssl, 그리고 admin kubeconfig 의 API 서버 주소
command -v openssl >/dev/null || echo "openssl 이 없음 — 먼저 설치할 것"
kubectl config view --minify -o jsonpath='API server: {.clusters[0].cluster.server}{"\n"}'

# 3) 시작 상태 확인: CSR jane 없음, dev 에 RBAC 없음
kubectl get csr jane 2>/dev/null || echo "CSR jane 없음 (정상)"
kubectl auth can-i list pods -n dev --as=jane || true    # no 가 정상
