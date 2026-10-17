#!/usr/bin/env bash
# e15 — Fix a crash-looping Deployment · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns jobs --ignore-not-found --wait=true
rm -rf /opt/course/e15

# 1) namespace + Deployment worker — command 에 오타(sleeep)가 있어 시작 메시지만 찍고 바로 죽는다
kubectl create ns jobs
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
  namespace: jobs
spec:
  replicas: 1
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      containers:
      - name: worker
        image: busybox:1.36
        command: ["sh", "-c", "echo worker starting; sleeep 3600"]
EOF

# 2) 한 번 이상 재시작할 때까지 기다린다 (그래야 --previous 로그가 생긴다)
for i in $(seq 1 60); do
  RC=$(kubectl -n jobs get pod -l app=worker -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 3) 답안 파일 디렉터리
mkdir -p /opt/course/e15

# 4) 설정 확인: STATUS 가 Error / CrashLoopBackOff, RESTARTS 1 이상
kubectl -n jobs get pods
