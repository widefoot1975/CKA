#!/usr/bin/env bash
# a14 — 실습 후 정리
# 실행: bash cleanup.sh
# namespace dev 는 A04(jane 의 Role/RoleBinding) 도 쓰므로 지우지 않고, 이 문제의 파드만 지운다
set -euo pipefail

kubectl -n dev delete pod broken-app --ignore-not-found
