#!/usr/bin/env bash
# f14 — kubectl cannot reach the API server · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: 실행하면 k8s-c1 의 kubectl 이 전부 실패한다. 다른 문제의 setup 은 이것보다 먼저 실행한다.
set -euo pipefail

KC=$HOME/.kube/config
ORIG=$HOME/.kube/config.f14.orig
[ -z "${KUBECONFIG:-}" ] || echo "주의: KUBECONFIG=$KUBECONFIG 가 설정되어 있습니다. 이 문제는 ~/.kube/config 를 씁니다 (unset KUBECONFIG)"

# 0) 처음 실행할 때 원본 kubeconfig 를 보관하고, 그다음부터는 원본으로 되돌린다
if [ -f "$ORIG" ]; then cp -p "$ORIG" "$KC"; else cp -p "$KC" "$ORIG"; fi
rm -rf /opt/course/f14

# 1) 장애 만들기: 현재 클러스터의 server 주소에서 포트만 6444 로 바꾼다
CL=$(kubectl --kubeconfig "$KC" config view --minify -o jsonpath='{.clusters[0].name}')
SERVER=$(kubectl --kubeconfig "$KC" config view --minify -o jsonpath='{.clusters[0].cluster.server}')
kubectl --kubeconfig "$KC" config set-cluster "$CL" --server="$(echo "$SERVER" | sed -E 's#:[0-9]+$##'):6444" >/dev/null

# 2) 시작 상태 확인: kubectl 이 connection refused 로 실패해야 한다
kubectl get nodes --request-timeout=5s || echo "kubectl 실패 (정상)"
