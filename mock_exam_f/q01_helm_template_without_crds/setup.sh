#!/usr/bin/env bash
# f01 — Helm chart without its CRDs · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전, helm 과 인터넷 연결 필요)
set -euo pipefail

command -v helm >/dev/null || { echo "helm 이 없습니다. https://helm.sh/docs/intro/install/ 로 먼저 설치하세요"; exit 1; }

# 0) 이전 실습 흔적 정리: 릴리스, 네임스페이스, 저장소 등록, 결과 파일, 지난번 CRD
helm uninstall argocd -n argocd 2>/dev/null || true
kubectl delete ns argocd --ignore-not-found --wait=true
helm repo remove argo 2>/dev/null || true
rm -rf /opt/course/f01
kubectl get crd -o name | grep 'argoproj.io' | xargs -r kubectl delete --wait=true

# 1) Argo CD CRD 세 개를 Helm 밖에서 설치 (Helm 라벨·어노테이션이 없는 상태)
#    applicationsets CRD 는 커서 client-side apply 의 어노테이션 크기 제한에 걸리므로 --server-side
BASE=https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds
kubectl apply --server-side \
  -f $BASE/application-crd.yaml \
  -f $BASE/applicationset-crd.yaml \
  -f $BASE/appproject-crd.yaml
kubectl wait crd/applications.argoproj.io crd/applicationsets.argoproj.io crd/appprojects.argoproj.io \
  --for=condition=Established --timeout=60s

# 2) 결과 파일 디렉터리 (비어 있는 상태)
mkdir -p /opt/course/f01

# 3) 시작 상태 확인: CRD 3개는 있고, 저장소 argo 와 릴리스 argocd 는 없다
kubectl get crd | grep argoproj.io
helm repo list 2>/dev/null | grep -w argo || echo "저장소 argo 없음 (정상)"
helm list -A | grep -w argocd || echo "릴리스 argocd 없음 (정상)"
