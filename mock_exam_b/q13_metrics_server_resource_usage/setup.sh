#!/usr/bin/env bash
# b13 — Restore metrics-server and analyse resource usage · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: metrics-server 를 일부러 고장 낸다. 실습 후 반드시 bash cleanup.sh 로 되돌린다.
#       namespace prod 는 mock_exam_c/q14 도 쓴다. 이 스크립트는 label q13=b13 이 붙은 것만 지우고 만든다.
set -euo pipefail

MS="kubectl -n kube-system"

# 0) 이전 실습 흔적 정리 (이 문제가 만든 것만)
kubectl -n prod delete deploy,hpa -l q13=b13 --ignore-not-found --wait=true 2>/dev/null || true
rm -rf /opt/q13

# 1) metrics-server 설치 (없으면)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 2) namespace prod (이미 있으면 그대로 쓴다) + 워크로드
#    api   : 컨테이너 app(CPU 최대 100m 사용) + log-agent(거의 놀음), 2 replicas
#    cache : polinux/stress 로 메모리 120M 를 잡고 있는 파드 → 메모리 1등
if ! kubectl get ns prod >/dev/null 2>&1; then
  kubectl create ns prod
  kubectl label ns prod q13=b13        # 이 문제가 만든 namespace 표시 (cleanup 이 비었을 때만 지운다)
fi
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: prod
  labels: {app: api, q13: b13}
spec:
  replicas: 2
  selector:
    matchLabels: {app: api}
  template:
    metadata:
      labels: {app: api, q13: b13}
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["sh", "-c", "while true; do :; done"]
        resources:
          requests: {cpu: 100m, memory: 16Mi}
          limits:   {cpu: 100m, memory: 64Mi}
      - name: log-agent
        image: busybox:1.36
        command: ["sh", "-c", "while true; do date; sleep 5; done"]
        resources:
          requests: {cpu: 50m, memory: 16Mi}
          limits:   {cpu: 100m, memory: 64Mi}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache
  namespace: prod
  labels: {app: cache, q13: b13}
spec:
  replicas: 1
  selector:
    matchLabels: {app: cache}
  template:
    metadata:
      labels: {app: cache, q13: b13}
    spec:
      containers:
      - name: cache
        image: polinux/stress
        command: ["stress"]
        args: ["--vm", "1", "--vm-bytes", "120M", "--vm-hang", "0"]
        resources:
          requests: {cpu: 10m, memory: 160Mi}
          limits:   {memory: 200Mi}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api
  namespace: prod
  labels: {q13: b13}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: api}
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target: {type: Utilization, averageUtilization: 80}
YAML
kubectl -n prod rollout status deploy api --timeout=180s
kubectl -n prod rollout status deploy cache --timeout=180s

# 3) 고장 내기: metrics-server 에서 --kubelet-insecure-tls 를 뺀다
#    → kubelet serving 인증서(자체 서명) 검증 실패 → 파드가 Ready 가 안 됨 → APIService False
#    기존 Ready 파드가 남지 않도록 0 으로 내렸다가 args 를 바꾸고 1 로 올린다
$MS scale deploy metrics-server --replicas=0
$MS wait pod -l k8s-app=metrics-server --for=delete --timeout=120s 2>/dev/null || true
args=$($MS get deploy metrics-server \
         -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}' \
       | grep -v -- '--kubelet-insecure-tls' | sed 's/.*/"&"/' | paste -sd, -)
$MS patch deploy metrics-server --type=json \
  -p="[{\"op\":\"replace\",\"path\":\"/spec/template/spec/containers/0/args\",\"value\":[$args]}]"
$MS scale deploy metrics-server --replicas=1

# 4) 답안 파일 디렉터리
mkdir -p /opt/q13

# 5) 시작 상태 확인: 1분 안에 kubectl top nodes 가 실패해야 한다
for _ in $(seq 1 12); do
  kubectl top nodes >/dev/null 2>&1 || break
  sleep 5
done
if kubectl top nodes >/dev/null 2>&1; then
  echo "경고: kubectl top nodes 가 아직 동작한다. 이 클러스터의 kubelet 인증서가 CA 서명(serverTLSBootstrap)이라 고장이 재현되지 않을 수 있다." >&2
else
  echo "준비 완료: kubectl top nodes 가 실패한다."
fi
kubectl -n prod get deploy,hpa
