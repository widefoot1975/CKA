#!/usr/bin/env bash
# f04 — Identify the CRI, CNI and CSI in use · 사전 환경 설정
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
set -euo pipefail

# 0) 노드 worker01 이 있는지 확인
kubectl get node worker01

# 1) 이전 실습 흔적 정리 — 답 파일 디렉터리
sudo rm -rf /opt/course/f04
sudo mkdir -p /opt/course/f04
sudo chown "$(id -u):$(id -g)" /opt/course/f04

# 2) CSI 드라이버가 하나도 없으면 4번 답이 빈 파일이 되므로, 연습용 CSIDriver 등록 오브젝트를 하나 만든다
#    (실제 드라이버는 없고 등록 정보만 있다 — 라벨 practice=f04 로 표시해 정리 때 이것만 지운다)
if [ -z "$(kubectl get csidrivers -o name)" ]; then
  kubectl apply -f - <<'YAML'
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: hostpath.csi.k8s.io
  labels: {practice: f04}
spec:
  attachRequired: false
  podInfoOnMount: true
  volumeLifecycleModes: [Persistent]
YAML
fi

# 3) 시작 상태 확인: 노드 목록, 등록된 CSI 드라이버
kubectl get nodes -o wide
kubectl get csidrivers
