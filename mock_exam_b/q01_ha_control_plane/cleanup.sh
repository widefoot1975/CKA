#!/usr/bin/env bash
# b01 — 실습 후 정리: cp03 을 컨트롤 플레인으로 다시 join 시켜 3대로 되돌린다.
# 문제를 다 풀었다면 1)~2) 는 이미 되어 있어서 건너뛴다.
# 실행: sudo bash cleanup.sh   (cp01 에서 root 로 실행) → 마지막에 나오는 명령을 cp03 에서 실행
set -euo pipefail
export KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}
FAILED=${FAILED:-cp03}
export ETCDCTL_ENDPOINTS=https://127.0.0.1:2379 \
       ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
       ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
       ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

# 0) 이미 다시 join 해서 멤버도 응답하고 노드도 Ready 면 할 일이 없다
LINE=$(etcdctl member list | awk -F', ' -v n="$FAILED" '$3==n')
URL=$(echo "$LINE" | awk -F', ' '{print $5}')
if [ -n "$LINE" ] && etcdctl endpoint health --endpoints="$URL" >/dev/null 2>&1 \
   && kubectl get node "$FAILED" --no-headers 2>/dev/null | grep -qw Ready; then
  rm -rf /opt/q01
  echo "$FAILED 는 이미 정상입니다. 답 디렉터리만 지웠습니다"; exit 0
fi

# 1) 낡은 멤버가 남아 있으면 제거 (0) 을 지났으니 응답하지 않는 멤버다)
if [ -n "$LINE" ]; then
  etcdctl member remove "$(echo "$LINE" | cut -d, -f1)"
fi

# 2) NotReady 로 남은 옛 Node 오브젝트 제거
if kubectl get node "$FAILED" --no-headers 2>/dev/null | grep -q NotReady; then
  kubectl delete node "$FAILED"
fi

# 3) 컨트롤 플레인 join 명령 (새 certificate key 포함)
KEY=$(kubeadm init phase upload-certs --upload-certs | tail -1)
JOIN=$(kubeadm token create --print-join-command --certificate-key "$KEY")
rm -rf /opt/q01

echo
echo "== $FAILED 에서 root 로 실행 =="
echo "kubeadm reset -f --skip-phases=remove-etcd-member && $JOIN"
echo
echo "== 그다음 cp01 에서 확인 =="
echo "kubectl get nodes -l node-role.kubernetes.io/control-plane ; etcdctl member list -w table"
