#!/usr/bin/env bash
# a17 — Control plane down from a static pod manifest error · 사전 환경 설정 (kube-apiserver 매니페스트에 플래그 오타를 낸다)
# 실행: cp01 에서 sudo bash setup.sh   (여러 번 실행해도 안전)
#       또는 k8s-c1 에서 ssh cp01 'sudo bash -s' < setup.sh
# 주의: 실행하면 이 클러스터의 kubectl 이 전부 멈춘다. 풀거나 cleanup.sh 를 돌려야 돌아온다.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash setup.sh"; exit 1; }
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 매니페스트 보관 위치 (반드시 매니페스트 디렉터리 밖)
[ -f $MAN/kube-apiserver.yaml ] || { echo "$MAN/kube-apiserver.yaml 이 없습니다. 컨트롤 플레인 노드에서 실행하세요."; exit 1; }

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (E13 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-apiserver.yaml ] || cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml

# 1) 원본 확인 후 보관
grep -q -- '- --authorization-mode=' $MAN/kube-apiserver.yaml || { echo "--authorization-mode 줄을 찾지 못했습니다."; exit 1; }
cp $MAN/kube-apiserver.yaml $KEEP/kube-apiserver.yaml

# 2) 고장 내기 ("동료의 수정"): 플래그 이름에 s 를 하나 더 붙인다 → kube-apiserver 가 시작하자마자 종료
sed -i 's#- --authorization-mode=#- --authorization-modes=#' $MAN/kube-apiserver.yaml

# 3) 시작 상태 확인: 1분쯤 뒤 kubectl 은 connection refused, crictl ps -a 에 Exited kube-apiserver
grep -n -- '--authorization-mode' $MAN/kube-apiserver.yaml
