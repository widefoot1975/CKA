#!/usr/bin/env bash
# f04 — 실습 후 정리 (setup 이 만든 연습용 CSIDriver 만 지운다. 원래 있던 드라이버는 건드리지 않는다)
# 실행: bash cleanup.sh   (k8s-c1 에서 실행)
set -euo pipefail

kubectl delete csidriver -l practice=f04 --ignore-not-found
sudo rm -rf /opt/course/f04
