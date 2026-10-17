#!/usr/bin/env bash
# q17 — Give a running Pod more memory without restarting it · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns perf --ignore-not-found --wait=true
rm -rf /opt/course/f17

# 1) metrics-server 가 없을 때만 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
if ! kubectl -n kube-system get deploy metrics-server >/dev/null 2>&1; then
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + 단독 파드 cache (Burstable: memory 64Mi / 128Mi)
kubectl create ns perf
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cache
  namespace: perf
  labels:
    app: cache
spec:
  containers:
  - name: app
    image: nginx:1.27
    resources:
      requests:
        memory: 64Mi
      limits:
        memory: 128Mi
EOF
kubectl -n perf wait pod cache --for=condition=Ready --timeout=120s

# 3) 답안 파일 디렉터리
mkdir -p /opt/course/f17

# 4) 첫 메트릭 수집까지 기다렸다가 확인 (1분 정도 걸릴 수 있음)
for i in $(seq 1 30); do
  kubectl -n perf top pod cache --containers >/dev/null 2>&1 && break
  sleep 5
done
kubectl -n perf top pod cache --containers
kubectl -n perf get pod cache \
  -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass,RESTARTS:.status.containerStatuses[0].restartCount
