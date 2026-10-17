#!/usr/bin/env bash
# b03 — Install a CRD and create a custom resource · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 이전 실습 흔적 정리 (그룹 training.example.com 의 CRD 를 지우면 Exercise 오브젝트도 모두 지워진다)
for c in $(kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="training.example.com")]}{.metadata.name}{"\n"}{end}'); do
  kubectl delete crd "$c" --wait=true
done
kubectl delete ns cka --ignore-not-found --wait=true
rm -rf /opt/q03

# 1) 문제에서 쓸 namespace 와 답 파일 디렉터리
kubectl create ns cka
mkdir -p /opt/q03

# 2) 시작 상태 확인: namespace 와 디렉터리는 있고, 그룹 training.example.com 은 아직 서비스되지 않아야 한다
kubectl get ns cka
ls -ld /opt/q03
kubectl api-resources --api-group=training.example.com
