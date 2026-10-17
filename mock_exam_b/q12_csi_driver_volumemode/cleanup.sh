#!/usr/bin/env bash
# b12 — 실습 후 정리 (setup 이 만든 것만 지운다. 원래 있던 CSIDriver·StorageClass 는 건드리지 않는다)
# 실행: bash cleanup.sh   (k8s-c1 에서 실행)
set -euo pipefail

# 파드가 loop 디바이스를 놓아야 떼어낼 수 있으므로 namespace 부터 지운다
kubectl delete ns raw --ignore-not-found --wait=true
kubectl delete pv -l practice=b12 --ignore-not-found --wait=true
kubectl delete sc -l practice=b12 --ignore-not-found
kubectl delete csidriver -l practice=b12 --ignore-not-found

ssh worker01 'sudo bash -s' <<'EOS'
set -euo pipefail
if [ -f /var/lib/b12/disk.img ]; then
  for DEV in $(losetup -j /var/lib/b12/disk.img | cut -d: -f1); do losetup -d "$DEV"; done
fi
rm -rf /var/lib/b12
EOS

sudo rm -rf /opt/q12
