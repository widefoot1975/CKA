# q03 — Install a CNI plugin that enforces NetworkPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c4` (→ `ssh <node>` if needed) |
| Target time | 6 min |

## Setup — 사전 환경 설정

이 문제는 **CNI 가 아직 없는 클러스터**에 CNI 를 처음 까는 문제라 **한 번 풀면 되돌리기 어렵다.** CNI 는 클러스터
전체의 파드 네트워크이고, 한 번 깐 CNI 를 지우거나 다른 CNI 로 바꾸면 모든 노드에 설정 파일·인터페이스·iptables
규칙이 남아 사실상 `kubeadm reset` 으로 다시 만들어야 한다. 그래서 setup 은 **이미 있는 CNI 를 지우지 않는다.**
매니페스트 두 벌(Flannel, Calico operator)을 `/opt/course/q03` 에 받아 두고, 이 클러스터에서 문제를 그대로 풀 수
있는지만 점검한다.

**문제 상태 만들기**: `kubeadm init --pod-network-cidr=10.244.0.0/16`(대역은 아무 값이나)으로 컨트롤 플레인을
만들고 워커를 join 한 뒤 **CNI 를 깔지 않은 채로** 둔다. 노드가 `NotReady`, CoreDNS 가 `Pending` 이면 된다.
**이 시점에 모든 노드의 VM 스냅샷을 찍어 두기를 권한다.** 스냅샷으로 되돌리면 같은 설치를 몇 번이고 다시 연습할 수 있다.

`k8s-c4` 에서 아래 스크립트를 실행한다. 클러스터를 바꾸지 않으므로 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q03_cni_install_networkpolicy
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 매니페스트 받기 + 연습 가능 여부 점검 (OK / NG 로 알려 준다)
bash cleanup.sh    # 실습 후 정리 (cni-test 와 /opt/course/q03 만 지운다)
```

점검이 모두 OK 이면 그대로 풀면 된다. 설정 직후 `/opt/course/q03/flannel/kube-flannel.yml` 과
`/opt/course/q03/calico/` 의 `operator-crds.yaml`, `tigera-operator.yaml`, `custom-resources.yaml`(IP 풀 기본값
`192.168.0.0/16` 그대로)이 있고, 노드는 `NotReady`, CoreDNS 는 `Pending` 이다. 4번을 위해 파드를 올릴 수 있는
노드가 두 개 이상 있어야 한다. 매니페스트와 이미지를 인터넷에서 받을 수 있어야 한다.

이미 CNI 가 있는 클러스터(NG)에서는 2·3번을 그대로 재현할 수 없다. 그 CNI 가 Calico 라면 1·4·5·6번만 연습하고,
Flannel 이라면 5번에서 정책이 **막지 않는 것**을 직접 확인해 볼 수 있다.
정리 스크립트는 설치한 CNI 를 지우지 않는다. 처음부터 다시 하려면 스냅샷으로 되돌리거나 모든 노드에서
`kubeadm reset` 후 다시 만든다. 실수로 Flannel 을 깔았을 때도 같다.

## Task

Cluster `k8s-c4` was just built with kubeadm. Every node is `NotReady` and the CoreDNS
pods are `Pending`. Two sets of CNI manifests are staged on the task host:

- `/opt/course/q03/flannel/kube-flannel.yml`
- `/opt/course/q03/calico/` — the Calico operator manifests and `custom-resources.yaml`

1. Find the pod CIDR the cluster was initialised with and write it to
   `/opt/course/q03/podcidr.txt`.
2. Install the one CNI that satisfies **both** requirements: pods on different nodes can
   reach each other, **and** NetworkPolicy is enforced. Use only the staged manifests (no
   Helm), and make its IP pool match the cluster's pod CIDR.
3. Confirm every node is `Ready`, the CoreDNS pods are `Running`, and a CNI configuration
   file exists under `/etc/cni/net.d/` on a worker node.
4. Prove pod-to-pod connectivity across nodes with two test pods pinned to different
   nodes in namespace `cni-test`.
5. Prove enforcement: after a default-deny ingress policy is applied in `cni-test`, the
   same request must fail.
6. State in one line why the other staged CNI would not satisfy the task.

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

[↑ 문항 목록](../README.md) · [← q02](../q02_kustomize_overlay_deploy/question.md) · [q04 →](../q04_operator_install_configure/question.md)
