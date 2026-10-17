#!/usr/bin/env bash
# b04 — Inspect the container runtime with crictl · 사전 환경 설정 (kube-apiserver 를 일부러 죽이고 /etc/crictl.yaml 을 치운다)
# 실행: cp01 에서 sudo bash setup.sh   (여러 번 실행해도 안전)
#       또는 k8s-c1 에서 ssh cp01 'sudo bash -s' < setup.sh
# 주의: 실행하면 이 클러스터의 kubectl 이 전부 멈춘다. cleanup.sh 를 돌려야 돌아온다.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash setup.sh"; exit 1; }
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 보관 위치 (반드시 매니페스트 디렉터리 밖)
SOCK=unix:///run/containerd/containerd.sock
[ -f $MAN/kube-apiserver.yaml ] || { echo "$MAN/kube-apiserver.yaml 이 없습니다. 컨트롤 플레인 노드에서 실행하세요."; exit 1; }

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (A17·E13 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-apiserver.yaml ] || cp $KEEP/kube-apiserver.yaml $MAN/kube-apiserver.yaml
rm -rf /opt/q04
mkdir -p /opt/q04

# 1) /etc/crictl.yaml 치우기: 처음 실행할 때만 원본을 보관한다 (원래 없었으면 표시 파일만 남긴다)
if [ ! -f $KEEP/crictl.yaml ] && [ ! -f $KEEP/crictl.yaml.absent ]; then
  if [ -f /etc/crictl.yaml ]; then mv /etc/crictl.yaml $KEEP/crictl.yaml; else touch $KEEP/crictl.yaml.absent; fi
else
  rm -f /etc/crictl.yaml       # 다시 실행: 지난번 실습에서 만든 파일을 지운다
fi

# 2) 원본 확인 후 보관: kubeadm 매니페스트의 --service-cluster-ip-range 줄이 있어야 한다
grep -q -- '- --service-cluster-ip-range=' $MAN/kube-apiserver.yaml || { echo "--service-cluster-ip-range 줄을 찾지 못했습니다. kubeadm 이 만든 원본인지 확인하세요."; exit 1; }
cp $MAN/kube-apiserver.yaml $KEEP/kube-apiserver.yaml

# 3) 고장 내기: 플래그 이름에 s 를 붙인다 → kube-apiserver 가 "unknown flag" 로 시작하자마자 종료 (CrashLoop)
sed -i 's#- --service-cluster-ip-range=#- --service-cluster-ip-ranges=#' $MAN/kube-apiserver.yaml

# 4) 시작 상태 확인: Exited 상태의 kube-apiserver 컨테이너가 생길 때까지 기다린다 (최대 3분)
for _ in $(seq 60); do
  crictl -r $SOCK ps -a -q --name kube-apiserver --state exited 2>/dev/null | grep -q . && break
  sleep 3
done
crictl -r $SOCK ps -a --name kube-apiserver 2>/dev/null
echo "이제 kubectl 은 응답하지 않는다. /etc/crictl.yaml 은 없다."
