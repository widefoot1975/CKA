#!/usr/bin/env bash
# e03 — 실습 후 정리
# 실행: bash cleanup.sh
set -euo pipefail

kubectl delete crd widgets.demo.example.com --ignore-not-found
rm -rf /opt/course/e03
