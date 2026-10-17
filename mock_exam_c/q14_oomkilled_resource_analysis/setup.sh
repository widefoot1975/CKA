#!/usr/bin/env bash
# c14 — A container is being OOMKilled · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 필요: 5번(in-place resize)은 v1.33 이상 (1.35 GA), kubectl 1.32 이상
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns prod --ignore-not-found --wait=true
rm -rf /opt/course/q14

# 1) metrics-server 설치 (2번의 kubectl top 용, 실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace + Deployment resizer — 150M 를 잡는데 limit 이 64Mi 라 OOMKilled 반복
#    (polinux/stress 는 쿠버네티스 공식 문서의 메모리 예제에서 쓰는 이미지)
kubectl create ns prod
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resizer
  namespace: prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: resizer
  template:
    metadata:
      labels:
        app: resizer
    spec:
      containers:
      - name: resizer
        image: polinux/stress
        command: ["stress"]
        args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "0"]
        resources:
          requests:
            memory: 32Mi
          limits:
            memory: 64Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: cache-warm
  namespace: prod
spec:
  containers:
  - name: cache
    image: busybox:1.36
    command: ["sh", "-c", "sleep 86400"]
    resources:
      requests:
        memory: 32Mi
      limits:
        memory: 64Mi
EOF

# 3) OOMKilled 기록이 한 번 생길 때까지 기다린다
for i in $(seq 1 60); do
  R=$(kubectl -n prod get pod -l app=resizer -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated.reason}' 2>/dev/null || true)
  [ "$R" = "OOMKilled" ] && break
  sleep 3
done
kubectl -n prod wait pod cache-warm --for=condition=Ready --timeout=120s

# 4) 설정 확인: resizer 는 RESTARTS 가 늘고, cache-warm 은 1/1 Running
kubectl -n prod get pods
