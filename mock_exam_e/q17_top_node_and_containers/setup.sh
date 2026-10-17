#!/usr/bin/env bash
# e17 — Analyse resource usage per node and container · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (monitoring 은 흔한 이름이라 이 문제가 만든 파드만 지운다)
kubectl -n monitoring delete pod -l cka=e17 --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/course/e17

# 1) metrics-server 설치 (실습 클러스터는 --kubelet-insecure-tls 필요)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
if ! kubectl -n kube-system get deploy metrics-server \
     -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -q -- '--kubelet-insecure-tls'; then
  kubectl -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi
kubectl -n kube-system rollout status deploy metrics-server --timeout=180s

# 2) namespace — 없을 때만 만들고, 이 문제가 만들었다는 표시(cka=e17)를 붙인다
if ! kubectl get ns monitoring >/dev/null 2>&1; then
  kubectl create ns monitoring
  kubectl label ns monitoring cka=e17
fi

# 3) 파드 두 개 — 메모리 tmpfs(emptyDir medium: Memory)에 파일을 써서 사용량을 고정한다
#    analytics: collector ≈ 40Mi + exporter ≈ 80Mi  → 파드 합계 ≈ 120Mi
#    cache-warmer: 컨테이너 하나 ≈ 95Mi             → 컨테이너 하나로는 가장 크지만 파드 합계는 2등
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: analytics
  namespace: monitoring
  labels:
    app: analytics
    cka: e17
spec:
  containers:
  - name: collector
    image: busybox:1.36
    command: ["sh", "-c", "head -c 40m /dev/zero > /fill/data; sleep 86400"]
    resources:
      limits:
        memory: 128Mi
    volumeMounts:
    - name: fill-collector
      mountPath: /fill
  - name: exporter
    image: busybox:1.36
    command: ["sh", "-c", "head -c 80m /dev/zero > /fill/data; sleep 86400"]
    resources:
      limits:
        memory: 160Mi
    volumeMounts:
    - name: fill-exporter
      mountPath: /fill
  volumes:
  - name: fill-collector
    emptyDir:
      medium: Memory
      sizeLimit: 64Mi
  - name: fill-exporter
    emptyDir:
      medium: Memory
      sizeLimit: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: cache-warmer
  namespace: monitoring
  labels:
    app: cache-warmer
    cka: e17
spec:
  containers:
  - name: warmer
    image: busybox:1.36
    command: ["sh", "-c", "head -c 95m /dev/zero > /fill/data; sleep 86400"]
    resources:
      limits:
        memory: 160Mi
    volumeMounts:
    - name: fill
      mountPath: /fill
  volumes:
  - name: fill
    emptyDir:
      medium: Memory
      sizeLimit: 120Mi
EOF
kubectl -n monitoring wait pod -l cka=e17 --for=condition=Ready --timeout=120s

# 4) 답안 파일 디렉터리
mkdir -p /opt/course/e17

# 5) 첫 수집까지 기다렸다가 확인 (1분 정도 걸릴 수 있음)
for i in $(seq 1 30); do
  kubectl -n monitoring top pod analytics --containers >/dev/null 2>&1 && break
  sleep 5
done
kubectl -n monitoring get pods
