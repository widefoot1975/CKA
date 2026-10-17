#!/usr/bin/env bash
# a12 — Access modes and reclaim policy · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 필요: k8s-c1 → worker01 로 ssh 가 되고, worker01 에서 sudo 를 암호 없이 쓸 수 있어야 한다.
# 주의: namespace ops 는 A11 도 쓰므로 지우지 않는다. 이 문제가 만드는 리소스만 이름으로 지운다.
set -euo pipefail

NODE=${NODE:-worker01}
kubectl get node "$NODE" >/dev/null
ssh "$NODE" true

# 0) 이전 실습 흔적 정리: 파드 → PVC → PV 순서로 지운다 (보호 finalizer 때문에 순서가 중요)
if kubectl get ns ops >/dev/null 2>&1; then
  kubectl -n ops delete pod writer reader --ignore-not-found --wait=true
  kubectl -n ops delete pvc pvc-a pvc-b pvc-d pvc-rwx --ignore-not-found --wait=true
fi
kubectl delete pv pv-retain pv-delete --ignore-not-found --wait=true

# 1) worker01 의 hostPath 디렉터리를 비운다 (지난번 파일이 남아 있으면 3단계 증명이 의미가 없다)
#    A11 의 /mnt/data/logs 는 건드리지 않는다
ssh "$NODE" sudo rm -rf /mnt/data/retain /mnt/data/delete

# 2) namespace ops 가 없으면 만든다
kubectl get ns ops >/dev/null 2>&1 || kubectl create ns ops

# 3) StorageClass slow 가 있으면 5단계 결과가 달라지므로 경고만 한다 (이 문제는 slow 를 PV 의 클래스 이름으로만 쓴다)
kubectl get sc slow >/dev/null 2>&1 && echo "경고: StorageClass slow 가 이미 있다 — 5단계에서 동적 프로비저닝이 일어날 수 있음"

# 4) 시작 상태 확인: pv-retain / pv-delete 가 없고, ops 에 이 문제의 PVC 가 없어야 함
kubectl get pv
kubectl -n ops get pvc
