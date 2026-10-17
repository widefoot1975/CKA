#!/usr/bin/env bash
# d16 — Read logs from an app and its sidecar · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 필요: 네이티브 사이드카(initContainers + restartPolicy: Always)는 v1.29 이상
set -euo pipefail

# 0) 이전 실습 흔적 정리
kubectl delete ns logs --ignore-not-found --wait=true
rm -rf /opt/course/d16

# 1) namespace + Pod order-api
#    - log-agent: 네이티브 사이드카, 시작하자마자 15줄을 찍고 5초마다 INFO/ERROR 를 남긴다
#    - api: 첫 실행은 FATAL 을 남기고 exit 1 → 한 번 재시작한 뒤에는 계속 돈다 (emptyDir 의 표식 파일로 구분)
kubectl create ns logs
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: order-api
  namespace: logs
spec:
  initContainers:
  - name: log-agent
    image: busybox:1.36
    restartPolicy: Always
    command:
    - sh
    - -c
    - |
      for i in $(seq 1 15); do echo "$(date -u +%FT%TZ) INFO agent ready, buffered line $i"; done
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 4)) -eq 0 ]; then echo "$(date -u +%FT%TZ) ERROR upstream rejected batch $i"
        else echo "$(date -u +%FT%TZ) INFO shipped batch $i"; fi
        sleep 5
      done
  containers:
  - name: api
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      if [ ! -f /state/started ]; then
        touch /state/started
        echo "$(date -u +%FT%TZ) INFO api starting (first run)"
        echo "$(date -u +%FT%TZ) FATAL cannot reach database, exiting"
        sleep 3
        exit 1
      fi
      echo "$(date -u +%FT%TZ) INFO api restarted, serving orders"
      i=0
      while true; do
        i=$((i+1))
        if [ $((i % 3)) -eq 0 ]; then echo "$(date -u +%FT%TZ) ERROR payment timeout order=$i"
        else echo "$(date -u +%FT%TZ) INFO order $i processed"; fi
        sleep 5
      done
    volumeMounts:
    - name: state
      mountPath: /state
  volumes:
  - name: state
    emptyDir: {}
EOF

# 2) api 가 한 번 재시작하고 파드가 Ready 가 될 때까지 기다린다
for i in $(seq 1 60); do
  RC=$(kubectl -n logs get pod order-api -o jsonpath='{.status.containerStatuses[?(@.name=="api")].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done
kubectl -n logs wait pod order-api --for=condition=Ready --timeout=120s

# 3) 답안 파일 디렉터리
mkdir -p /opt/course/d16

# 4) 설정 확인: READY 2/2, RESTARTS 1
kubectl -n logs get pod order-api
