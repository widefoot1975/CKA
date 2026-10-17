#!/usr/bin/env bash
# a02 — Upgrade the cluster lifecycle with kubeadm · 사전 점검
# 컨트롤 플레인 버전은 스크립트로 내릴 수 없다. 대신 이 클러스터에서 "한 마이너 올리기"를 연습할 수 있는지 확인한다.
# 실행: sudo bash setup.sh   (cp01 에서 root 로 실행, 여러 번 실행해도 안전 — 아무것도 바꾸지 않는다)
set -euo pipefail
export KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}
LIST=/etc/apt/sources.list.d/kubernetes.list

[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요 (sudo -i)"; exit 1; }

# 1) 지금 버전: 노드별 kubelet, 컨트롤 플레인
kubectl get nodes
CP=$(kubectl get --raw /version | grep -o '"gitVersion": *"v[0-9.]*' | grep -o '[0-9][0-9.]*')
CUR=$(echo "$CP" | cut -d. -f1,2)
NEXT=$(echo "$CUR" | awk -F. '{printf "%d.%d", $1, $2+1}')
echo "컨트롤 플레인 v$CP → 연습 목표 v$NEXT"

# 2) 노드 버전이 모두 같은지 (워커가 한 마이너 낮으면 F03 부터 끝내고 오는 것이 좋다)
kubectl get nodes -o jsonpath='{range .items[*]}{.status.nodeInfo.kubeletVersion}{"\n"}{end}' | sort -u

# 3) 저장소 파일 위치와 지금 가리키는 마이너
grep -o 'core:/stable:/v[0-9.]*' $LIST || { echo "$LIST 에 pkgs.k8s.io 저장소가 없습니다"; exit 1; }

# 4) 다음 마이너 패키지가 공개되어 있는지 (없으면 이 클러스터는 이미 최신 → 한 마이너 낮게 다시 만들어야 연습 가능)
if curl -fsSL -o /dev/null "https://pkgs.k8s.io/core:/stable:/v$NEXT/deb/Release"; then
  echo "OK: v$NEXT 저장소가 있습니다. 업그레이드를 연습할 수 있습니다"
else
  echo "NG: v$NEXT 저장소가 아직 없습니다. 클러스터를 v$(echo "$CUR" | awk -F. '{printf "%d.%d", $1, $2-1}') 로 다시 만들어야 연습할 수 있습니다"
fi

# 5) 컨트롤 플레인 컴포넌트 상태 (업그레이드 전 기준)
kubectl -n kube-system get pods -l tier=control-plane -o wide
