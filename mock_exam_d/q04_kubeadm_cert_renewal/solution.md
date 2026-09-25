# q04 — Check and renew a control plane certificate · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터는 kubeadm으로 구성되어 있다. 보안팀은 다른 인증서는 건드리지 않고 API 서버의 서빙 인증서만
지금 갱신하기를 원한다. `cp01` 에서 작업하고 답 파일도 거기에 쓴다.

1. `kubeadm certs check-expiration` 의 출력을 `/opt/course/d04/before.txt` 에 저장한다.
2. kubeadm으로 `apiserver` 인증서**만** 갱신한다.
3. 실행 중인 kube-apiserver가 갱신된 인증서를 읽어 들이게 한다.
4. `openssl` 이 보여 주는 `/etc/kubernetes/pki/apiserver.crt` 의 새 만료일(`notAfter`)을
   `/opt/course/d04/apiserver-enddate.txt` 에 적는다.

## 모범 풀이

**1) 만료일 확인**

```bash
ssh cp01
sudo -i
mkdir -p /opt/course/d04
kubeadm certs check-expiration | tee /opt/course/d04/before.txt
# CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
# admin.conf                 Mar 02, 2027 09:10 UTC   156d            ca                      no
# apiserver                  Mar 02, 2027 09:10 UTC   156d            ca                      no
# apiserver-etcd-client      Mar 02, 2027 09:10 UTC   156d            etcd-ca                 no
# ...  (그 아래에 CA 인증서 표가 따로 나온다)
```

목록에 `kubelet.conf` 는 없습니다. kubelet은 자기 클라이언트 인증서를 스스로 교체(rotation)하기 때문입니다.

**2) apiserver 인증서만 갱신**

```bash
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate    # 갱신 전 값
kubeadm certs renew apiserver
# certificate for serving the Kubernetes API renewed
```

인자로 준 인증서 하나만 갱신합니다. 이름은 `check-expiration` 의 첫 열과 같습니다. `kubeadm certs renew all`
은 "다른 인증서는 건드리지 않는다"는 요구를 어깁니다. 또 `all` 은 `admin.conf` 도 갱신하므로, 썼다면
`cp /etc/kubernetes/admin.conf ~/.kube/config` 로 kubeconfig도 새것으로 바꿔 둡니다.

**3) kube-apiserver 재시작 — 이 문제의 핵심입니다**

`kubeadm certs renew` 는 **디스크의 파일만** 바꿉니다. 이미 떠 있는 kube-apiserver는 시작할 때 읽은 옛
인증서로 계속 서비스하고, kubelet도 인증서 파일이 바뀌었다고 파드를 재시작해 주지 않습니다. 정적 파드는
매니페스트를 디렉터리 밖으로 잠시 옮겼다가 되돌려서 재시작합니다. `kubectl delete pod kube-apiserver-cp01` 은
API에 보이는 **미러 파드**만 지울 뿐 컨테이너는 그대로라서 재시작이 되지 않습니다.

```bash
mv /etc/kubernetes/manifests/kube-apiserver.yaml /root/
sleep 20
crictl ps --name kube-apiserver       # 비어 있어야 한다 (그동안 kubectl도 응답하지 않는다)
mv /root/kube-apiserver.yaml /etc/kubernetes/manifests/
crictl ps --name kube-apiserver       # 새 컨테이너, CREATED 가 몇 초 전
```

**4) 새 만료일 기록**

```bash
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate \
  | tee /opt/course/d04/apiserver-enddate.txt
# notAfter=Sep 26 10:20:00 2027 GMT        ← 오늘부터 약 1년 뒤
```

## 검증

```bash
kubeadm certs check-expiration | grep -E '^(apiserver|admin.conf) '
# admin.conf   Mar 02, 2027 09:10 UTC   156d  ...   ← 그대로
# apiserver    Sep 26, 2027 10:20 UTC   364d  ...   ← 갱신됨
echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | openssl x509 -noout -enddate
# notAfter=Sep 26 10:20:00 2027 GMT        ← 실제로 서빙 중인 인증서도 새것
kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes    # API 정상 응답
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubeadm certs renew <이름>` → 해당 정적 파드 재시작(매니페스트를 밖으로 옮겼다 되돌리기) → `openssl x509 -noout -enddate` 로 확인.
- **헷갈리는 지점**: `check-expiration` 은 **파일**의 만료일을 보여 줄 뿐, 실행 중인 프로세스가 어떤 인증서를 쓰는지는 알려 주지 않습니다. 실제로 서빙되는 인증서는 `openssl s_client` 로 확인합니다. `kubelet.conf` 가 목록에 없는 것은 정상이고, `kubeadm upgrade apply` 는 기본적으로 인증서를 함께 갱신합니다.

## 참고 문서

- 검색어: `certificate management with kubeadm`
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
- https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
