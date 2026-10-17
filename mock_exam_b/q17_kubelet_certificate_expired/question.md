# q17 — Node lost after kubelet client certificate expiry

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 5 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 7 min |

## Setup — 사전 환경 설정

이 문제는 **노드를 일부러 고장 낸 상태에서** 시작한다. `k8s-c1` 에서 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다.
setup 은 `cp01` 의 클러스터 CA 로 인증서를 서명하고 `worker02` 에 끼워 넣으므로, `k8s-c1` 에서 `kubectl` 이 되고
`k8s-c1` → `cp01`, `k8s-c1` → `worker02` 로 ssh 가 되며, 두 노드에서 sudo 를 암호 없이 쓸 수 있어야 한다.
실습이 끝나면 반드시 정리(cleanup)해서 `worker02` 를 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q17_kubelet_certificate_expired
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q16](../q16_control_plane_component_down/question.md)
