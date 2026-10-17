#!/usr/bin/env bash
# c05 — Self-healing with StatefulSet and DaemonSet · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# namespace infra 는 다른 문제(mock_exam_e q08)도 쓰므로 namespace 를 지우지 않고 이 문제의 객체만 정리한다.
set -euo pipefail

# 0) 이전 실습 흔적 정리 (이 문제가 만드는 객체만)
kubectl -n infra delete ds node-agent --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n infra delete sts cache --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n infra delete pod -l app=cache --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n infra delete svc cache --ignore-not-found --wait=true 2>/dev/null || true

# 1) namespace — 없을 때만 만들고, 이 스크립트가 만들었다는 표시를 남긴다 (cleanup 이 이 표시를 보고 판단)
if ! kubectl get ns infra >/dev/null 2>&1; then
  kubectl create ns infra
  kubectl label ns infra cka-lab-c05=created --overwrite
fi

# 2) 문제에서 "이미 있다"고 한 헤드리스 Service cache (selector app=cache, 포트 6379)
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: cache
  namespace: infra
  labels:
    cka-lab-c05: "true"
spec:
  clusterIP: None
  selector:
    app: cache
  ports:
  - name: redis
    port: 6379
    targetPort: 6379
EOF

# 3) 설정 확인: CLUSTER-IP 가 None 이어야 한다
kubectl -n infra get svc cache -o wide
