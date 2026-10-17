#!/usr/bin/env bash
# a04 — 실습 후 정리
# 실행: bash cleanup.sh   (k8s-c1 에서 root 로 실행)
# namespace dev 는 q14 도 쓰므로 지우지 않고, 이 문제가 만든 것만 지운다
set -euo pipefail

kubectl delete csr jane --ignore-not-found
kubectl -n dev delete rolebinding jane-pod-reader --ignore-not-found
kubectl -n dev delete role pod-reader --ignore-not-found
kubectl -n dev delete pod a04-web --ignore-not-found
rm -f /root/jane.key /root/jane.csr /root/jane.crt /root/jane.kubeconfig /root/jane-csr.yaml /root/k8s-c1-ca.crt
