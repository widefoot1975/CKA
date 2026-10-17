#!/usr/bin/env bash
# b17 — 실습 후 정리 (worker02 의 kubelet.conf 와 /var/lib/kubelet/pki 를 setup 이 보관한 원본으로 되돌리고 kubelet 을 재시작한다)
# 실행: bash cleanup.sh   (k8s-c1 에서 실행)
set -euo pipefail

NODE=${NODE:-worker02}
CP=${CP:-cp01}

{ echo "NODE='$NODE'"; cat <<'REMOTE'
set -euo pipefail
KEEP=/root/.cka-setup/b17
CONF=/etc/kubernetes/kubelet.conf
BOOT=/etc/kubernetes/bootstrap-kubelet.conf
if [ -f "$KEEP/kubelet.conf" ]; then
  cp -p "$KEEP/kubelet.conf" "$CONF"
  rm -rf /var/lib/kubelet/pki && tar -C /var/lib/kubelet -xpf "$KEEP/pki.tar"
  # 원래 bootstrap 파일이 없었다면, 풀이 중에 만든 bootstrap 파일(토큰이 들어 있다)도 지운다
  if [ -f "$KEEP/bootstrap-kubelet.conf" ]; then cp -p "$KEEP/bootstrap-kubelet.conf" "$BOOT"; else rm -f "$BOOT"; fi
  rm -rf "$KEEP"
else
  echo "$KEEP 에 보관된 원본이 없습니다. kubelet 설정은 그대로 두고 답 파일만 지웁니다"
fi
rm -rf /opt/q17
systemctl restart kubelet
REMOTE
} | ssh "$NODE" sudo bash -s

# 풀이 중 cp01 에 만들었을 수 있는 kubeconfig 사본 (모범 풀이의 경로)
ssh "$CP" sudo rm -f "/tmp/$NODE-kubelet.conf"

kubectl wait node "$NODE" --for=condition=Ready --timeout=120s
ssh "$NODE" sudo openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -enddate
