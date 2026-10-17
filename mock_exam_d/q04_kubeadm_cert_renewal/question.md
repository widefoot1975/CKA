# q04 — Check and renew a control plane certificate

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `cp01` 에서 root(`sudo -i`)로 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
kubeadm 으로 만든 클러스터라면 따로 만들 리소스는 없다. 답 파일 디렉터리를 비우고, 지난 실습에서
kube-apiserver 매니페스트를 밖에 둔 채 끝났는지만 확인한다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) cp01 에서 root 로
sudo -i

# 1) 지난 실습에서 매니페스트를 밖으로 옮겨 둔 채 끝났으면 되돌린다
ls /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null \
  || mv /root/kube-apiserver.yaml /etc/kubernetes/manifests/

# 2) 이전 실습 흔적 정리 — 답 파일 디렉터리를 비워서 새로 만든다
rm -rf /opt/course/d04
mkdir -p /opt/course/d04

# 3) 시작 상태 확인: 매니페스트 디렉터리에는 yaml 4개만, apiserver 인증서의 현재 만료일
ls /etc/kubernetes/manifests
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate
kubeadm certs check-expiration | grep -E '^(CERTIFICATE|admin.conf|apiserver) '
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
sudo bash setup.sh      # 환경 만들기
sudo bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/d04` 는 비어 있고, `/etc/kubernetes/manifests` 에는 `etcd`, `kube-apiserver`,
`kube-controller-manager`, `kube-scheduler` 매니페스트 4개만 있다. 3) 에서 본 `notAfter` 값을 기억해 두면
갱신 뒤 날짜가 바뀌었는지 비교할 수 있다.
실습용 클러스터를 막 만들었다면 인증서가 이미 1년짜리라 갱신 전후 날짜 차이가 몇 분~며칠뿐이다. 날짜보다
**시각**이 바뀌었는지로 확인한다.
갱신한 인증서는 정상적인 새 인증서라 되돌릴 필요가 없다. 정리 때는 답 파일만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
ls /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null \
  || mv /root/kube-apiserver.yaml /etc/kubernetes/manifests/
rm -rf /opt/course/d04
```

</details>

## Task

The cluster was built with kubeadm. The security team wants the API server's serving
certificate renewed now, without touching any other certificate. Work on `cp01` and write the
answer files there.

1. Save the output of `kubeadm certs check-expiration` to `/opt/course/d04/before.txt`.
2. Renew only the `apiserver` certificate using kubeadm.
3. Make the running kube-apiserver load the renewed certificate.
4. Write the new expiry date (`notAfter`) of `/etc/kubernetes/pki/apiserver.crt`, as printed by
   `openssl`, to `/opt/course/d04/apiserver-enddate.txt`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
