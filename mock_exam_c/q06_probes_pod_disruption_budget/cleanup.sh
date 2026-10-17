#!/usr/bin/env bash
# c06 — 실습 후 정리 (shop 은 다른 문제도 쓰므로 비어 있을 때만 지운다)
# 실행: bash cleanup.sh
set -euo pipefail

# 1) 6번에서 drain 한 노드를 되돌린다 — setup 전부터 cordon 되어 있던 노드는 건드리지 않는다
PRE=/tmp/cka-c06-precordoned.txt
for n in $(kubectl get nodes -o jsonpath='{range .items[?(@.spec.unschedulable==true)]}{.metadata.name}{"\n"}{end}'); do
  if [ -f "$PRE" ] && grep -qx "$n" "$PRE"; then continue; fi
  kubectl uncordon "$n"
done
rm -f "$PRE"

# 2) 이 문제의 리소스만 지운다
kubectl -n shop delete pdb api-pdb --ignore-not-found
kubectl -n shop delete svc api --ignore-not-found
kubectl -n shop delete deploy api --ignore-not-found --wait=true

# 3) shop 에 다른 리소스가 없으면 namespace 도 지운다
LEFT=$(kubectl -n shop get all,pdb,cm,secret,ingress -o name 2>/dev/null \
  | grep -v -e '^configmap/kube-root-ca.crt$' | wc -l || true)
if kubectl get ns shop >/dev/null 2>&1 && [ "$LEFT" -eq 0 ]; then
  kubectl delete ns shop
fi
kubectl get nodes
