# q04 — Inspect a highly-available control plane

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c3` → `ssh cp01`, then `sudo -i` |
| Target time | 6 min |

## Setup — 사전 환경 설정

정보를 모으기만 하는 문제라 만들 리소스는 없다. 답 디렉터리를 비우고, 호스트에 `etcdctl` 이 없으면 etcd
파드와 같은 버전으로 설치하고, 클러스터가 어떤 모양인지 확인한다.
`cp01` 에서 root(`sudo -i`)로 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q04_ha_control_plane_inspect
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
sudo bash setup.sh      # 환경 만들기
sudo bash cleanup.sh    # 실습 후 정리
```

설정 직후 `/opt/course/e04` 는 비어 있고 `etcdctl version` 이 동작한다.
문제는 컨트롤 플레인 3대짜리 stacked HA 클러스터를 가정한다. 실습 클러스터가 컨트롤 플레인 1대여도 명령은
똑같이 연습할 수 있고, 답만 달라진다(노드 이름 1개, 멤버 수 1).
`kubeadm init` 때 `--control-plane-endpoint` 를 주지 않았다면 `kubeadm-config` 에 `controlPlaneEndpoint` 줄이
아예 없다. 그때는 `endpoint.txt` 가 빈 파일인 것이 맞는 답이고, 스크립트가 그 사실을 알려 준다.
설치한 `etcdctl` 은 B01 같은 다른 etcd 문제에서도 쓰므로 정리할 때 남겨 둔다.

## Task

Cluster `k8s-c3` runs a stacked highly-available control plane (etcd runs on every control plane
node) with three control plane nodes. Nothing is broken; you only need to collect facts.

1. Write the `controlPlaneEndpoint` value from ConfigMap `kubeadm-config` in namespace
   `kube-system` to `/opt/course/e04/endpoint.txt`.
2. Write the names of all control plane nodes to `/opt/course/e04/cp-nodes.txt`, one per line.
3. On `cp01`, use `etcdctl` with the etcd server certificate files in `/etc/kubernetes/pki/etcd/`
   to write the number of etcd members to `/opt/course/e04/members.txt`, and confirm that every
   member reports healthy.

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

[↑ 문항 목록](../README.md) · [← q03](../q03_crd_install_custom_resource/question.md) · [q05 →](../q05_hpa_behavior/question.md)
