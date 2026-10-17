#!/usr/bin/env bash
# d14 — 실습 후 정리 (kube-scheduler 매니페스트를 원본으로 되돌린다)
# 실행: cp01 에서 sudo bash cleanup.sh
#       또는 k8s-c1 에서 ssh cp01 'sudo bash -s' < cleanup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash cleanup.sh"; exit 1; }
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup
mkdir -p $KEEP

# 1) setup.sh 가 보관한 원본으로 되돌린다
if [ -f $KEEP/kube-scheduler.yaml ]; then
  cp $KEEP/kube-scheduler.yaml $MAN/kube-scheduler.yaml
  rm $KEEP/kube-scheduler.yaml
fi

# 2) 매니페스트 디렉터리 안에 남은 백업(.bak 등)은 kubelet 이 파드로 읽으므로 밖으로 옮긴다
for f in $MAN/*kube-scheduler*; do
  [ "$f" = $MAN/kube-scheduler.yaml ] || mv -v "$f" $KEEP/
done

# 3) 실습 산출물 정리
rm -rf /opt/course/d14
kubectl delete pod sched-test --ignore-not-found || true

# 4) kube-scheduler 컨테이너가 다시 Running 이 될 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do crictl ps --name kube-scheduler -q | grep -q . && break; sleep 3; done
crictl ps --name kube-scheduler
kubectl -n kube-system get pods -l component=kube-scheduler
