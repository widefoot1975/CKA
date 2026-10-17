# q04 — Create a kubeconfig for a certificate-based user

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 **root 로**(`sudo -i`) 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q04_kubeconfig_certificate_management
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후에는 namespace `dev` 에 파드 `a04-web` 하나가 떠 있고, CSR `jane`, Role `pod-reader`, RoleBinding `jane-pod-reader`,
`/root/jane.*` 파일은 하나도 없다. 키 생성부터 kubeconfig, RBAC까지 전부 직접 만든다.
`dev` 는 q14 도 쓰는 네임스페이스라 정리할 때 지우지 않고, 이 문제가 만든 것만 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q03](../q03_helm_release_lifecycle/question.md) · [q05 →](../q05_deployment_rollout_rollback/question.md)
