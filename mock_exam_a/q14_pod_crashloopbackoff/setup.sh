#!/usr/bin/env bash
# a14 — Diagnose a CrashLoopBackOff pod · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 — namespace dev 는 A04 도 쓰므로 지우지 않고 파드만 지운다
kubectl -n dev delete pod broken-app --ignore-not-found --wait=true 2>/dev/null || true
kubectl get ns dev >/dev/null 2>&1 || kubectl create ns dev

# 1) 고장 내기: 시작할 때 약 48MB 를 메모리에 올리는데 memory limit 이 32Mi 라 OOMKilled(137) 로 죽는다
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: broken-app
  namespace: dev
  labels:
    app: broken-app
spec:
  restartPolicy: Always
  containers:
  - name: app
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      echo "broken-app starting"
      echo "loading cache (48MB) ..."
      CACHE=$(head -c 50331648 /dev/zero | tr '\0' x)
      echo "cache loaded, serving"
      while true; do sleep 3600; done
    resources:
      requests:
        memory: 16Mi
      limits:
        memory: 32Mi
YAML

# 2) 한 번 이상 재시작할 때까지 기다린다 (그래야 lastState 와 --previous 로그가 생긴다)
for i in $(seq 1 60); do
  RC=$(kubectl -n dev get pod broken-app -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 3) 설정 확인: STATUS 가 OOMKilled / CrashLoopBackOff, RESTARTS 1 이상
kubectl -n dev get pod broken-app
