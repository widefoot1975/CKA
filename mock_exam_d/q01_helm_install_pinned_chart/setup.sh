#!/usr/bin/env bash
# d01 — Install and upgrade a Helm release · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) helm 이 설치되어 있는지 확인 (없으면 여기서 멈춘다)
helm version --short

# 1) 이전 실습 흔적 정리: 릴리스, 네임스페이스, 저장소, 결과 파일
if helm status podinfo -n demo >/dev/null 2>&1; then
  helm uninstall podinfo -n demo --wait
fi
kubectl delete ns demo --ignore-not-found --wait=true
helm repo remove podinfo >/dev/null 2>&1 || true
rm -rf /opt/course/d01

# 2) 결과 파일 디렉터리
mkdir -p /opt/course/d01

# 3) 시작 상태 확인: 저장소·네임스페이스·릴리스가 모두 없어야 한다
helm repo list 2>/dev/null | grep podinfo || echo "podinfo 저장소 없음 (정상)"
kubectl get ns demo 2>/dev/null || echo "namespace demo 없음 (정상)"
