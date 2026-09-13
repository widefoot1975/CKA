# q04 — Create a kubeconfig for a certificate-based user · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

새 운영자 `jane` 이 본인 클라이언트 인증서로 클러스터에 접근해야 한다.

1. 2048비트 RSA 키 `/root/jane.key` 와 subject가 `CN=jane`, `O=dev-team` 인 CSR `/root/jane.csr` 을 만든다.
2. 이것을 CertificateSigningRequest `jane` 으로 제출한다. signer는 `kubernetes.io/kube-apiserver-client`, usage는 `client auth`, 유효기간은 1일. 승인하고 발급된 인증서를 `/root/jane.crt` 로 저장한다.
3. 독립 kubeconfig `/root/jane.kubeconfig` 를 만든다. cluster `k8s-c1`(admin kubeconfig와 같은 API 서버 주소·CA), user `jane`, 현재 컨텍스트는 `jane@k8s-c1`. 인증서는 파일에 임베드한다.
4. Role `pod-reader` 와 RoleBinding `jane-pod-reader` 로 `dev` 네임스페이스의 `pods` 에 대한 `get`, `list`, `watch` 를 `jane` 에게 부여한다.
5. `/root/jane.kubeconfig` 만 써서 `jane` 이 `dev` 의 파드는 조회하고 `default` 의 파드는 조회하지 못함을 보인다.

## 모범 풀이

**1) 키와 CSR**

```bash
openssl genrsa -out /root/jane.key 2048
openssl req -new -key /root/jane.key -out /root/jane.csr -subj "/CN=jane/O=dev-team"
```

**2) CSR 오브젝트 제출·승인**

`request` 는 CSR 파일 전체를 base64로 인코딩한 값이며 **줄바꿈이 없어야** 합니다(`-w 0`).

```bash
cat /root/jane.csr | base64 -w 0
```

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jane
spec:
  request: <위 출력 한 줄>
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
```

```bash
kubectl apply -f jane-csr.yaml
kubectl get csr jane                 # CONDITION Pending
kubectl certificate approve jane     # CONDITION Approved,Issued
kubectl get csr jane -o jsonpath='{.status.certificate}' | base64 -d > /root/jane.crt
```

**3) kubeconfig**

```bash
KC=/root/jane.kubeconfig
API=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

kubectl config set-cluster k8s-c1 --server=$API \
  --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true --kubeconfig=$KC
kubectl config set-credentials jane \
  --client-certificate=/root/jane.crt --client-key=/root/jane.key --embed-certs=true --kubeconfig=$KC
kubectl config set-context jane@k8s-c1 --cluster=k8s-c1 --user=jane --kubeconfig=$KC
kubectl config use-context jane@k8s-c1 --kubeconfig=$KC
```

**4) RBAC**

```bash
kubectl -n dev create role pod-reader --verb=get,list,watch --resource=pods
kubectl -n dev create rolebinding jane-pod-reader --role=pod-reader --user=jane
```

**인증서는 권한을 하나도 주지 않습니다.** 인증서가 하는 일은 "나는 jane 이다"를 증명하는 인증(authentication)까지이고, 무엇을 할 수 있는지는 RBAC이 따로 정합니다. 4단계를 빼면 3단계까지 완벽해도 모든 요청이 `Forbidden` 입니다. 그리고 이름은 인증서에서 옵니다 — **`CN` 이 사용자 이름, `O` 가 그룹**입니다. 그래서 RoleBinding의 `--user=jane` 이 CSR의 `CN=jane` 과 한 글자라도 다르면 연결되지 않습니다. `--group=dev-team` 으로 묶을 수도 있습니다.

`--embed-certs=true` 를 빼면 kubeconfig에 파일 경로만 기록되어, 파일을 다른 곳으로 옮기면 바로 깨집니다.

## 검증

```bash
openssl x509 -in /root/jane.crt -noout -subject       # subject=CN=jane, O=dev-team

kubectl --kubeconfig=/root/jane.kubeconfig -n dev get pods       # 목록 출력
kubectl --kubeconfig=/root/jane.kubeconfig -n default get pods   # Error ... Forbidden

kubectl auth can-i list pods -n dev --as=jane          # yes
kubectl auth can-i list pods -n default --as=jane      # no
kubectl config current-context --kubeconfig=/root/jane.kubeconfig   # jane@k8s-c1
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 인증서 = 인증(누구인가), RBAC = 인가(무엇을 할 수 있나). 둘 다 있어야 동작한다. `CN`=user, `O`=group.
- **헷갈리는 지점**: `kubectl config set-credentials` 는 `--client-key`(키 파일)를 받고, `set-cluster` 는 `--certificate-authority`(CA)를 받습니다. 둘을 뒤집으면 `x509: certificate signed by unknown authority` 가 납니다. 또 `kubectl config` 계열은 `--kubeconfig` 없이 쓰면 조용히 `~/.kube/config` 를 고쳐 admin 설정을 망칩니다.

## 참고 문서

- 검색어: `certificate signing requests`
- https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
