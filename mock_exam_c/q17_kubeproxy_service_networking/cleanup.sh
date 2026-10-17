#!/usr/bin/env bash
# c17 — 실습 후 정리 (kube-proxy 를 모든 노드로 되돌리고 Service 룰이 다시 써질 때까지 기다린다)
# 실행: bash cleanup.sh [노드이름]   (k8s-c1 에서, 기본 노드는 worker01)
#       namespace app 은 다른 문제도 쓰므로 이 문제가 만든 리소스만 지운다
set -euo pipefail
NODE=${1:-worker01}
DS="-n kube-system ds/kube-proxy"

# 1) DaemonSet nodeSelector 원복 + 노드 라벨 제거 (풀 때 라벨 방식으로 고쳤어도 같이 지운다)
if kubectl get $DS -o jsonpath='{.spec.template.spec.nodeSelector}' | grep -q '"kube-proxy"'; then
  kubectl patch $DS --type=json -p='[{"op":"remove","path":"/spec/template/spec/nodeSelector/kube-proxy"}]'
fi
kubectl label nodes --all kube-proxy- >/dev/null 2>&1 || true
kubectl -n kube-system delete pod c17-reboot-sim --ignore-not-found
kubectl rollout status $DS --timeout=300s

# 2) 대상 노드에 kube-proxy 가 다시 Ready 인지 확인 (시작하면서 룰을 전부 다시 쓴다)
if kubectl get node "$NODE" >/dev/null 2>&1; then
  kubectl -n kube-system wait pod -l k8s-app=kube-proxy --field-selector spec.nodeName=$NODE \
    --for=condition=Ready --timeout=180s
fi
kubectl -n kube-system get ds kube-proxy

# 3) 이 문제가 만든 리소스만 정리
kubectl -n app delete deploy web --ignore-not-found
kubectl -n app delete svc web web-np --ignore-not-found
kubectl -n app delete pod client dbg v v2 --ignore-not-found
