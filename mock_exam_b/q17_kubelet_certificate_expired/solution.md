# q17 — Node lost after kubelet client certificate expiry · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`worker02` 가 `NotReady` 가 되었다. kubelet은 실행 중이지만 API server에 대해 `Unauthorized` 를
로그에 남긴다. 컨트롤 플레인은 정상이고 다른 노드는 모두 문제없다.

1. `worker02` 에서 kubelet 클라이언트 인증서가 만료되었음을 확인하고 `notAfter` 날짜를
   `/opt/q17/expiry.txt` 에 적는다.
2. `/etc/kubernetes/kubelet.conf` 가 인증서를 내장하고 있는지, `/var/lib/kubelet/pki` 아래의
   회전되는 파일을 가리키는지 판단한다. 어느 쪽인지와 그 경로를 `/opt/q17/identity.txt` 에 적는다.
3. 노드를 재설치하지 않고 `worker02` 를 `Ready` 로 되돌린다.
4. 수정 과정에서 생기는 CertificateSigningRequest를 승인하고, 노드의 새 클라이언트 인증서
   만료일을 보인다.
5. 컨트롤 플레인에서 `kubeadm certs renew all` 을 실행해도 이 문제가 해결되지 않는 이유를
   `/opt/q17/why.txt` 에 적는다.

## 모범 풀이

**1단계 — kubelet 이 무엇으로 인증하는지 먼저 확인합니다.** 두 가지 형태가 있고 조사 경로가
달라집니다.

```bash
grep -E 'client-certificate|client-key' /etc/kubernetes/kubelet.conf
```

```
# (A) 회전형 — kubeadm 기본값. pem 파일을 직접 읽으면 된다
client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
# (B) 내장형 — 오래된 클러스터나 수동 설치. base64 를 풀어야 보인다
client-certificate-data: LS0tLS1CRUdJTi...
```

```bash
# (A)
openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -enddate -subject
# notAfter=Aug 14 09:22:17 2026 GMT
# subject=O = system:nodes, CN = system:node:worker02

# (B)
grep client-certificate-data /etc/kubernetes/kubelet.conf | awk '{print $2}' \
  | base64 -d | openssl x509 -noout -enddate -subject

journalctl -u kubelet --since '-10min' | grep -iE 'unauthorized|certificate|expired'
# Unable to register node ... Unauthorized
# part of the existing bootstrap client certificate in ... is expired
```

| 증상 | 원인 | 조치 |
|---|---|---|
| `Unauthorized`, pem의 notAfter가 과거 | 클라이언트 인증서 만료 | 아래 재발급 |
| `x509: certificate signed by unknown authority` | CA 불일치 | `kubelet.conf` 의 `certificate-authority-data` 확인 |
| `connection refused` to :6443 | API server 다운 | 컨트롤 플레인 조사 |
| 노드 NotReady + `NetworkPluginNotReady` | CNI 문제 | q15 경로 |
| CSR이 `Pending` 으로 쌓임 | 자동 승인 미동작 | `kubectl certificate approve` |

**2단계 — 복구.** 자동 회전은 **만료 전에만** 동작합니다. kubelet은 수명의 약 70~80%가 지날 때
새 인증서를 요청하는데, 그 요청 자체를 기존 인증서로 인증하기 때문입니다. 완전히 만료되면
스스로 회복할 수 없고, 이것이 이 문제의 핵심입니다. 그래서 **bootstrap 을 다시 태워야** 합니다.

가장 빠른 길은 컨트롤 플레인에서 kubeconfig를 직접 발급해 복사하는 것입니다. 조직과 CN이
정확해야 합니다 — `O=system:nodes`, `CN=system:node:<노드이름>` 이 아니면 Node authorizer가
거부합니다.

```bash
# cp01 에서
kubeadm kubeconfig user --org system:nodes --client-name system:node:worker02 \
  > /tmp/worker02-kubelet.conf
scp /tmp/worker02-kubelet.conf worker02:/etc/kubernetes/kubelet.conf

# worker02 에서
rm -f /var/lib/kubelet/pki/kubelet-client-*.pem
systemctl restart kubelet
```

원래대로 회전형으로 되돌리려면 bootstrap을 다시 태웁니다. `kubeadm token create` 로 토큰을 받아
`/etc/kubernetes/bootstrap-kubelet.conf` 에 `token:` 으로 넣고, `kubelet.conf` 와 만료된 pem을
치운 뒤 kubelet을 재시작하면 kubelet이 CSR을 제출해 새 `kubelet.conf` 와
`kubelet-client-current.pem` 을 **스스로 만듭니다.**

**3단계 — CSR 승인.** `kubelet-client` CSR은 보통 자동 승인되지만, 남아 있으면 직접 승인합니다.

```bash
kubectl get csr
# NAME        SIGNERNAME                                    REQUESTOR                 CONDITION
# csr-x7k2p   kubernetes.io/kube-apiserver-client-kubelet   system:bootstrap:abcdef   Pending
kubectl certificate approve csr-x7k2p
```

**5단계 — 답.** `kubeadm certs renew all` 은 컨트롤 플레인 노드의 인증서와 `admin.conf`,
`controller-manager.conf`, `scheduler.conf` 만 갱신합니다. 워커의 kubelet 클라이언트 인증서는
kubelet의 회전 기능이 관리하는 대상이라 kubeadm이 손대지 않습니다 —
`kubeadm certs check-expiration` 출력에서도 `kubelet.conf` 행에 "certificate is managed by
kubelet rotation" 취지의 주석이 붙습니다. 게다가 그 명령은 **컨트롤 플레인 노드에서** 도는 것이라
워커의 파일에 접근할 수도 없습니다.

## 검증

```bash
kubectl get nodes
# worker02   Ready   <none>   ...

openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -enddate -subject
# notAfter 가 약 1년 뒤, subject 에 CN=system:node:worker02

kubectl get csr | grep -c Pending          # 0
journalctl -u kubelet --since '-3min' | grep -ci unauthorized   # 0
kubectl logs -n kube-system <worker02의 파드>   # kubelet 10250 도 응답하는지 교차 확인
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: kubelet의 인증서 자동 회전은 만료 **전에만** 동작한다. 완전히 만료되면 bootstrap 토큰으로 CSR을 다시 받아야 하고, `kubeadm certs renew` 는 워커의 kubelet 인증서를 갱신하지 않는다.
- **헷갈리는 지점**: 인증서가 두 종류입니다 — kubelet **client** 인증서(kubelet이 API server에 접속할 때 쓰는 신원, `kubelet-client-current.pem`)와 kubelet **serving** 인증서(API server나 metrics-server가 kubelet의 10250에 접속할 때 kubelet이 제시, `kubelet.crt`/`kubelet-server-current.pem`). client가 만료되면 노드가 NotReady가 되고, serving이 문제면 노드는 Ready인데 `kubectl logs`/`exec`/`top` 만 실패합니다. 증상이 다르므로 먼저 어느 쪽인지 가릅니다.

## 참고 문서

- 검색어: `certificate rotation kubelet`
- https://kubernetes.io/docs/tasks/tls/certificate-rotation/
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
