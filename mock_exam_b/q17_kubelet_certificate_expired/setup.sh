#!/usr/bin/env bash
# b17 — Node lost after kubelet client certificate expiry · 사전 환경 설정
#        (worker02 의 kubelet 클라이언트 인증서를 이미 만료된 인증서로 바꿔 끼운다)
# 실행: bash setup.sh   (k8s-c1 에서 실행, 여러 번 실행해도 안전)
# 필요: k8s-c1 에서 kubectl 이 되고, k8s-c1 → cp01, k8s-c1 → worker02 로 ssh 가 되며,
#       두 노드에서 sudo 를 암호 없이 쓸 수 있어야 한다.
# 주의: 실행하면 worker02 가 NotReady 가 된다. 실습이 끝나면 꼭 cleanup.sh 를 실행한다.
set -euo pipefail

NODE=${NODE:-worker02}
CP=${CP:-cp01}
kubectl get node "$NODE" >/dev/null
ssh "$CP" sudo test -f /etc/kubernetes/pki/ca.key || { echo "$CP 에 /etc/kubernetes/pki/ca.key 가 없습니다. 컨트롤 플레인 노드 이름을 CP=... 로 주세요"; exit 1; }

# 0~1) worker02 에서: 처음 실행할 때 원본을 보관하고, 그다음부터는 원본으로 되돌린 뒤 새 키와 CSR 을 만든다
#      (CSR 은 base64 한 줄로 stdout 에 내보내고, 나머지 메시지는 stderr 로 보낸다)
CSR_B64=$({ echo "NODE='$NODE'"; cat <<'REMOTE'
set -euo pipefail
KEEP=/root/.cka-setup/b17          # 원본 보관 위치
CONF=/etc/kubernetes/kubelet.conf
BOOT=/etc/kubernetes/bootstrap-kubelet.conf
PKI=/var/lib/kubelet/pki
[ -f "$CONF" ] || { echo "$CONF 가 없습니다. kubeadm 으로 join 한 노드에서 실행하세요" >&2; exit 1; }
mkdir -p "$KEEP"
if [ -f "$KEEP/kubelet.conf" ]; then
  cp -p "$KEEP/kubelet.conf" "$CONF"
  rm -rf "$PKI" && tar -C /var/lib/kubelet -xpf "$KEEP/pki.tar"
  if [ -f "$KEEP/bootstrap-kubelet.conf" ]; then cp -p "$KEEP/bootstrap-kubelet.conf" "$BOOT"; else rm -f "$BOOT"; fi
else
  cp -p "$CONF" "$KEEP/kubelet.conf"
  tar -C /var/lib/kubelet -cpf "$KEEP/pki.tar" pki
  [ ! -f "$BOOT" ] || cp -p "$BOOT" "$KEEP/bootstrap-kubelet.conf"
fi
rm -rf /opt/q17
mkdir -p /opt/q17

# kubelet 이 만드는 것과 같은 형태: ECDSA P-256 키, O=system:nodes, CN=system:node:<노드이름>
openssl ecparam -name prime256v1 -genkey -noout -out "$KEEP/expired.key"
openssl req -new -key "$KEEP/expired.key" -subj "/O=system:nodes/CN=system:node:$NODE" | base64 -w0
REMOTE
} | ssh "$NODE" sudo bash -s)

# 2) cp01 에서: 클러스터 CA 로 서명하되 유효 기간을 과거로 잡는다 (425일 전 ~ 60일 전, 1년짜리가 두 달 전에 만료된 모양)
CRT_B64=$({ echo "CSR_B64='$CSR_B64'"; cat <<'REMOTE'
set -euo pipefail
D=$(mktemp -d); trap 'rm -rf "$D"' EXIT
echo "$CSR_B64" | base64 -d > "$D/req.csr"
touch "$D/index.txt"; openssl rand -hex 16 > "$D/serial"
cat > "$D/ca.cnf" <<EOF
[ ca ]
default_ca = b17
[ b17 ]
database = $D/index.txt
new_certs_dir = $D
serial = $D/serial
default_md = sha256
policy = pol
x509_extensions = ext
unique_subject = no
[ pol ]
organizationName = supplied
commonName = supplied
[ ext ]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = clientAuth
authorityKeyIdentifier = keyid
EOF
openssl ca -batch -notext -config "$D/ca.cnf" \
  -cert /etc/kubernetes/pki/ca.crt -keyfile /etc/kubernetes/pki/ca.key \
  -in "$D/req.csr" -out "$D/out.crt" \
  -startdate "$(date -u -d '-425 days' +%y%m%d%H%M%SZ)" \
  -enddate "$(date -u -d '-60 days' +%y%m%d%H%M%SZ)" >"$D/log" 2>&1 || { cat "$D/log" >&2; exit 1; }
base64 -w0 < "$D/out.crt"
REMOTE
} | ssh "$CP" sudo bash -s)

# 3) worker02 에서: 만료된 인증서를 kubelet 이 읽는 자리에 끼우고 kubelet 을 재시작한다
{ echo "CRT_B64='$CRT_B64'"; cat <<'REMOTE'
set -euo pipefail
KEEP=/root/.cka-setup/b17
CONF=/etc/kubernetes/kubelet.conf
PKI=/var/lib/kubelet/pki
echo "$CRT_B64" | base64 -d > "$KEEP/expired.crt"
if grep -q '^ *client-certificate-data:' "$CONF"; then
  # 내장형 kubelet.conf: base64 값을 바꿔 넣는다
  sed -i "s|^\( *client-certificate-data:\).*|\1 $(base64 -w0 < "$KEEP/expired.crt")|" "$CONF"
  sed -i "s|^\( *client-key-data:\).*|\1 $(base64 -w0 < "$KEEP/expired.key")|" "$CONF"
else
  # 회전형(kubeadm 기본): 인증서+키를 한 pem 에 담고 current 심볼릭 링크를 그 파일로 돌린다
  PEM="$PKI/kubelet-client-$(date -u -d '-425 days' +%Y-%m-%d-%H-%M-%S).pem"
  cat "$KEEP/expired.crt" "$KEEP/expired.key" > "$PEM"
  chmod 600 "$PEM"
  ln -sfn "$PEM" "$PKI/kubelet-client-current.pem"
fi
rm -f "$KEEP/expired.crt" "$KEEP/expired.key"
# bootstrap 파일이 남아 있으면 kubelet 이 스스로 다시 bootstrap 하므로 치운다 (kubeadm join 도 끝나면 지운다)
rm -f /etc/kubernetes/bootstrap-kubelet.conf
systemctl restart kubelet || true
REMOTE
} | ssh "$NODE" sudo bash -s

# 4) 시작 상태 확인: 노드가 NotReady(Ready=Unknown) 가 될 때까지 최대 2분 기다린다
for _ in $(seq 1 24); do
  st=$(kubectl get node "$NODE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
  [ "$st" != "True" ] && break
  sleep 5
done
kubectl get nodes
