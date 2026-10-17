# q04 — Check and renew a control plane certificate

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh cp01`, then `sudo -i` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `cp01` 에서 root(`sudo -i`)로 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
kubeadm 으로 만든 클러스터라면 따로 만들 리소스는 없다. 답 파일 디렉터리를 비우고, 지난 실습에서
kube-apiserver 매니페스트를 밖에 둔 채 끝났는지만 확인한다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_d/q04_kubeadm_cert_renewal
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q03](../q03_crd_explore_explain/question.md) · [q05 →](../q05_deployment_scale_rollout_undo/question.md)
