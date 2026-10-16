#!/usr/bin/env bash
# f10 — CoreDNS static hosts entry · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 처음 실행할 때 원본 Corefile 을 보관하고, 그다음부터는 그 원본으로 되돌린다 (= 이전 실습 흔적 정리)
ORIG=/opt/course/f10-corefile.orig
mkdir -p /opt/course
if [ -f "$ORIG" ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile="$ORIG" --dry-run=client -o yaml | kubectl replace -f -
  kubectl -n kube-system rollout restart deploy coredns
else
  kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' > "$ORIG"
fi
kubectl -n kube-system rollout status deploy coredns --timeout=120s

# 1) 백업 파일을 둘 디렉터리 (비어 있는 상태)
rm -rf /opt/course/f10
mkdir -p /opt/course/f10

# 2) 시작 상태 확인: Corefile 에 db.internal 이 없음
kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' | grep -n 'db.internal' || echo "db.internal 없음 (정상)"
ls -ld /opt/course/f10
