#!/usr/bin/env bash
# c13 — Cluster DNS resolution is failing · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 주의: 실행하면 클러스터 전체의 DNS 가 멈춘다. 실습이 끝나면 꼭 cleanup.sh 를 실행한다.
set -euo pipefail

# 0) 처음 실행할 때 원본 Corefile 을 보관하고, 그다음부터는 그 원본으로 되돌린다 (= 이전 실습 흔적 정리)
#    원본 파일 없이 이 문제의 고장이 남아 있으면 그 한 글자를 되돌려서 보관한다
ORIG=/opt/course/c13-corefile.orig
mkdir -p /opt/course
if [ -f "$ORIG" ]; then
  kubectl -n kube-system create cm coredns --from-file=Corefile="$ORIG" --dry-run=client -o yaml | kubectl replace -f -
  kubectl -n kube-system rollout restart deploy coredns
else
  kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' \
    | sed -E 's/^([[:space:]]*)kubernets([[:space:]])/\1kubernetes\2/' > "$ORIG"
fi
# e16 실습이 레플리카 0 으로 남겨 두었으면 kubeadm 기본값 2 로 (파드가 있어야 이 문제의 증상이 보인다)
if [ "$(kubectl -n kube-system get deploy coredns -o jsonpath='{.spec.replicas}')" = "0" ]; then
  kubectl -n kube-system scale deploy coredns --replicas=2
fi
kubectl -n kube-system rollout status deploy coredns --timeout=120s
rm -rf /opt/course/q13

# 1) 확인용 Service backend.app (namespace app 은 f09 도 쓰므로 이 문제 것에만 라벨 course=c13 을 단다)
if ! kubectl get ns app >/dev/null 2>&1; then
  kubectl create ns app
  kubectl label ns app course=c13
fi
kubectl -n app delete deploy,svc -l course=c13 --ignore-not-found --wait=true
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: app
  labels: {course: c13}
spec:
  replicas: 1
  selector:
    matchLabels: {c13: backend}
  template:
    metadata:
      labels: {c13: backend}
    spec:
      containers:
      - name: web
        image: nginx:1.27
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: app
  labels: {course: c13}
spec:
  selector: {c13: backend}
  ports:
  - port: 80
    targetPort: 80
YAML
kubectl -n app rollout status deploy backend --timeout=120s

# 2) 장애 만들기 (내용은 풀이에서 확인)
sed -E 's/^([[:space:]]*)kubernetes([[:space:]])/\1kubernets\2/' "$ORIG" > /opt/course/c13-corefile.broken
kubectl -n kube-system create cm coredns --from-file=Corefile=/opt/course/c13-corefile.broken --dry-run=client -o yaml | kubectl replace -f -
rm -f /opt/course/c13-corefile.broken
kubectl -n kube-system delete pod -l k8s-app=kube-dns --wait=false
for i in $(seq 1 40); do
  R=$(kubectl -n kube-system get pod -l k8s-app=kube-dns \
        -o jsonpath='{range .items[*]}{.status.containerStatuses[0].restartCount}{"\n"}{end}' 2>/dev/null | sort -n | head -1 || true)
  [ -n "$R" ] && [ "$R" -ge 1 ] && break
  sleep 3
done
kubectl -n kube-system get pods -l k8s-app=kube-dns

# 3) 시작 상태 확인: 파드 IP 로는 닿지만 이름은 해석되지 않는다
BIP=$(kubectl -n app get pod -l c13=backend -o jsonpath='{.items[0].status.podIP}')
echo "backend 파드 IP: $BIP"
kubectl delete pod c13-check --ignore-not-found --wait=true
kubectl run c13-check --rm -i --restart=Never --image=busybox:1.36 -- sh -c \
  "wget -qO- -T 3 http://$BIP >/dev/null && echo 'pod IP: OK'; nslookup backend.app.svc.cluster.local || echo 'name: FAIL (정상)'" || true
