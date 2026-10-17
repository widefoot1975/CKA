# q17 — Node lost after kubelet client certificate expiry

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **노드를 일부러 고장 낸 상태에서** 시작한다. `k8s-c1` 에서 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다.
setup 은 `cp01` 의 클러스터 CA 로 인증서를 서명하고 `worker02` 에 끼워 넣으므로, `k8s-c1` 에서 `kubectl` 이 되고
`k8s-c1` → `cp01`, `k8s-c1` → `worker02` 로 ssh 가 되며, 두 노드에서 sudo 를 암호 없이 쓸 수 있어야 한다.
실습이 끝나면 반드시 정리(cleanup)해서 `worker02` 를 원래대로 돌려놓는다.

**방법 A — 명령어를 복사해서 붙여 넣기** (`k8s-c1` 에서)

<details><summary>명령어 펼치기 — 고장 내는 내용이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
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
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
# k8s-c1 에서 (스크립트가 알아서 cp01, worker02 로 ssh 한다)
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리

# 노드 이름이 다르면
NODE=worker02 CP=cp01 bash setup.sh
```

설정 후 2분 안에 `kubectl get nodes` 에서 `worker02` 가 `NotReady` 가 된다. `worker02` 의 kubelet 서비스는
계속 재시작되고, 다른 노드와 컨트롤 플레인은 정상이다. `worker02` 의 `/opt/q17/` 는 비어 있다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`worker02` 에서 새 키와 CSR(`O=system:nodes`, `CN=system:node:worker02`)을 만들고, `cp01` 에서 클러스터 CA 로
유효 기간을 **425일 전 ~ 60일 전**으로 잡아 서명한다. 그 인증서를 kubelet 이 읽는 자리에 끼운다. kubeadm 기본값처럼
`kubelet.conf` 가 `/var/lib/kubelet/pki/kubelet-client-current.pem` 을 가리키면 새 pem 을 만들고 심볼릭 링크를 그쪽으로
돌린다. `kubelet.conf` 에 인증서가 내장되어 있으면 `client-certificate-data`/`client-key-data` 값을 바꾼다.
`/etc/kubernetes/bootstrap-kubelet.conf` 가 남아 있으면 kubelet 이 스스로 다시 bootstrap 하므로 치운다.

고장 내기 전에 `kubelet.conf`, `/var/lib/kubelet/pki` 전체, bootstrap 파일(있다면)을 `worker02` 의
`/root/.cka-setup/b17/` 에 보관한다. 두 번째 실행부터는 먼저 이 원본으로 되돌린 뒤 다시 고장 낸다. `cleanup.sh` 는
원본 세 가지를 되돌리고, 원래 없던 bootstrap 파일은 지우고, `/opt/q17` 과 `cp01` 의 `/tmp/worker02-kubelet.conf` 를
지운 뒤 kubelet 을 재시작하고 노드가 `Ready` 가 될 때까지 기다린다. CA 와 다른 노드는 건드리지 않는다.

</details>

<details><summary>정리 명령 (방법 A, k8s-c1 에서)</summary>

```bash
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
```

</details>

## Task

`worker02` went `NotReady`. Its kubelet service keeps restarting, and the kubelet journal
complains about its client certificate. The control plane is healthy and every other node
is fine.

1. On `worker02`, confirm the kubelet client certificate has expired and write its
   `notAfter` date to `/opt/q17/expiry.txt`.
2. Determine whether `/etc/kubernetes/kubelet.conf` carries an embedded certificate or
   points at a rotating file under `/var/lib/kubelet/pki`. Write which, and the path, to
   `/opt/q17/identity.txt`.
3. Bring `worker02` back to `Ready` without reinstalling the node.
4. Approve any CertificateSigningRequest your fix creates, and show the node's new client
   certificate expiry.
5. Write to `/opt/q17/why.txt` why running `kubeadm certs renew all` on the control plane
   would not have fixed this.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
