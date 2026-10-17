#!/usr/bin/env bash
# e16 — Cluster DNS stopped working · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: 실행하면 클러스터 전체의 DNS 가 멈춘다. 실습이 끝나면 꼭 cleanup.sh 를 실행한다.
set -euo pipefail

# 0) 이전 실습 결과 파일 정리
rm -rf /opt/course/e16

# 1) 장애 만들기 (내용은 풀이에서 확인)
kubectl -n kube-system scale deploy coredns --replicas=0
kubectl -n kube-system wait pod -l k8s-app=kube-dns --for=delete --timeout=120s 2>/dev/null || true

# 2) 시작 상태 확인: Service kube-dns 는 그대로 있다
kubectl -n kube-system get svc kube-dns
