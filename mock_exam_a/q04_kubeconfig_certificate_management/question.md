# q04 — Create a kubeconfig for a certificate-based user

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 **root 로**(`sudo -i`) 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 — CSR, RBAC, /root 의 jane 파일
#    namespace dev 는 q14 도 쓰므로 지우지 않는다
kubectl delete csr jane --ignore-not-found
kubectl -n dev delete rolebinding jane-pod-reader --ignore-not-found 2>/dev/null || true
kubectl -n dev delete role pod-reader --ignore-not-found 2>/dev/null || true
rm -f /root/jane.key /root/jane.csr /root/jane.crt /root/jane.kubeconfig /root/jane-csr.yaml /root/k8s-c1-ca.crt

# 1) 대상 namespace dev 와, 목록에 보일 파드 하나
kubectl create ns dev --dry-run=client -o yaml | kubectl apply -f -
kubectl -n dev run a04-web --image=nginx:1.27 --labels=app=a04-web \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n dev wait --for=condition=Ready pod/a04-web --timeout=120s || \
  echo "a04-web 이 아직 Ready 가 아님 — 목록 확인에는 지장 없음"

# 2) 도구 확인: openssl, 그리고 admin kubeconfig 의 API 서버 주소
command -v openssl >/dev/null || echo "openssl 이 없음 — 먼저 설치할 것"
kubectl config view --minify -o jsonpath='API server: {.clusters[0].cluster.server}{"\n"}'

# 3) 시작 상태 확인: CSR jane 없음, dev 에 RBAC 없음
kubectl get csr jane 2>/dev/null || echo "CSR jane 없음 (정상)"
kubectl auth can-i list pods -n dev --as=jane || true    # no 가 정상
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후에는 namespace `dev` 에 파드 `a04-web` 하나가 떠 있고, CSR `jane`, Role `pod-reader`, RoleBinding `jane-pod-reader`,
`/root/jane.*` 파일은 하나도 없다. 키 생성부터 kubeconfig, RBAC까지 전부 직접 만든다.
`dev` 는 q14 도 쓰는 네임스페이스라 정리할 때 지우지 않고, 이 문제가 만든 것만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete csr jane --ignore-not-found
kubectl -n dev delete rolebinding jane-pod-reader --ignore-not-found
kubectl -n dev delete role pod-reader --ignore-not-found
kubectl -n dev delete pod a04-web --ignore-not-found
rm -f /root/jane.key /root/jane.csr /root/jane.crt /root/jane.kubeconfig /root/jane-csr.yaml /root/k8s-c1-ca.crt
```

</details>

## Task

A new operator `jane` must reach the cluster with her own client certificate.

1. Generate a 2048-bit RSA key `/root/jane.key` and a CSR `/root/jane.csr` with subject
   `CN=jane`, `O=dev-team`.
2. Submit it as a CertificateSigningRequest `jane` — signer
   `kubernetes.io/kube-apiserver-client`, usage `client auth`, one day of validity. Approve
   it and save the issued certificate to `/root/jane.crt`.
3. Build a standalone kubeconfig `/root/jane.kubeconfig`: cluster `k8s-c1` with the admin
   kubeconfig's endpoint and CA, user `jane`, current context `jane@k8s-c1`, certs embedded.
4. Grant `jane` `get`, `list` and `watch` on `pods` in `dev` with a Role `pod-reader` and a
   RoleBinding `jane-pod-reader`.
5. With only `/root/jane.kubeconfig`, show `jane` lists pods in `dev` and not in `default`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
