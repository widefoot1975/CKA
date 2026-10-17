#!/usr/bin/env bash
# d14 — Pods stay Pending because the scheduler is broken · 사전 환경 설정 (kube-scheduler 이미지 태그를 일부러 틀리게)
# 실행: cp01 에서 sudo bash setup.sh   (여러 번 실행해도 안전)
#       또는 k8s-c1 에서 ssh cp01 'sudo bash -s' < setup.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "root 로 실행하세요: sudo bash setup.sh"; exit 1; }
export KUBECONFIG=/etc/kubernetes/admin.conf
MAN=/etc/kubernetes/manifests
KEEP=/root/.cka-setup          # 원본 매니페스트 보관 위치 (반드시 매니페스트 디렉터리 밖)
[ -f $MAN/kube-scheduler.yaml ] || { echo "$MAN/kube-scheduler.yaml 이 없습니다. 컨트롤 플레인 노드에서 실행하세요."; exit 1; }

# 0) 이전 실습 흔적 정리: 보관해 둔 원본이 있으면 먼저 되돌린다 (A17·B16 등 다른 문제가 남긴 것 포함)
mkdir -p $KEEP
[ ! -f $KEEP/kube-scheduler.yaml ] || cp $KEEP/kube-scheduler.yaml $MAN/kube-scheduler.yaml
rm -rf /opt/course/d14
mkdir -p /opt/course/d14
kubectl delete pod sched-test --ignore-not-found || true

# 1) 원본 확인: kube-scheduler 와 kube-apiserver 의 이미지 태그가 같아야 정상
TAG=$(grep -m1 'image:' $MAN/kube-apiserver.yaml | sed 's/.*://')
echo "kube-apiserver 태그: $TAG"
grep -q "kube-scheduler:$TAG\$" $MAN/kube-scheduler.yaml || { echo "kube-scheduler 태그가 $TAG 와 다릅니다. 원본이 아닌 것 같아 멈춥니다."; exit 1; }
cp $MAN/kube-scheduler.yaml $KEEP/kube-scheduler.yaml

# 2) 고장 내기: 태그 끝에 x 를 붙인다 (없는 태그 → ErrImagePull / ImagePullBackOff)
sed -i "s#kube-scheduler:$TAG\$#kube-scheduler:${TAG}x#" $MAN/kube-scheduler.yaml

# 3) 시작 상태 확인: 30초~1분 뒤 kube-scheduler-<노드이름> 이 ImagePullBackOff
grep 'image:' $MAN/kube-scheduler.yaml
sleep 30
kubectl -n kube-system get pods -l component=kube-scheduler
