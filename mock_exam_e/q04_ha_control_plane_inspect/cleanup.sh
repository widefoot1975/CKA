#!/usr/bin/env bash
# e04 — 실습 후 정리 (답 파일만 지운다. 설치한 etcdctl 은 다른 문제에서도 쓰므로 남긴다)
# 실행: sudo bash cleanup.sh   (cp01 에서 root 로 실행)
set -euo pipefail

rm -rf /opt/course/e04
