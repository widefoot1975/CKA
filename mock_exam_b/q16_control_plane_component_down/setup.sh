#!/usr/bin/env bash
# b16 — A control plane component is not running · 사전 환경 설정 (kube-scheduler 매니페스트의 들여쓰기를 일부러 깨뜨린다)
# 실행: cp01 에서 sudo bash setup.sh   (여러 번 실행해도 안전)
#       또는 k8s-c1 에서 ssh cp01 'sudo bash -s' < setup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash setup.sh"; exit 1; }
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 매니페스트 보관 위치 (반드시 매니페스트 디렉터리 밖)
[ -f $MAN/kube-scheduler.yaml ] || { echo "$MAN/kube-scheduler.yaml 이 없습니다. 컨트롤 플레인 노드에서 실행하세요."; exit 1; }

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (D14 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-scheduler.yaml ] || cp $KEEP/kube-scheduler.yaml $MAN/kube-scheduler.yaml
rm -rf /opt/q16
mkdir -p /opt/q16
kubectl delete pod sched-test --ignore-not-found || true

# 1) 원본 확인 후 보관: kubeadm 매니페스트의 "    image:" 줄(공백 4칸)이 한 줄 있어야 한다
[ "$(grep -c '^    image: ' $MAN/kube-scheduler.yaml)" -eq 1 ] || { echo "예상한 image: 줄을 찾지 못했습니다. kubeadm 이 만든 원본인지 확인하세요."; exit 1; }
cp $MAN/kube-scheduler.yaml $KEEP/kube-scheduler.yaml

# 2) 고장 내기: image: 줄의 들여쓰기를 4칸 → 3칸으로 (yaml 파싱 실패 → kubelet 이 파드를 아예 만들지 않음)
sed -i 's/^    image: /   image: /' $MAN/kube-scheduler.yaml

# 3) 시작 상태 확인: 1분쯤 뒤 kube-scheduler 파드가 kube-system 목록에서 사라진다 (kubelet 이 20초 주기로 디렉터리를 다시 읽음)
sleep 45
kubectl -n kube-system get pods -l component=kube-scheduler
echo "이제 새 파드를 만들면 Pending 에 머물고 이벤트도 없다"
