# q04 — Inspect a highly-available control plane

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c3` → `ssh cp01`, then `sudo -i` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

정보를 모으기만 하는 문제라 만들 리소스는 없다. 답 디렉터리를 비우고, 호스트에 `etcdctl` 이 없으면 etcd
파드와 같은 버전으로 설치하고, 클러스터가 어떤 모양인지 확인한다.
`cp01` 에서 root(`sudo -i`)로 아래 둘 중 하나를 실행한다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) cp01 에서 root 로
sudo -i
export KUBECONFIG=/etc/kubernetes/admin.conf

# 1) 이전 실습 흔적 정리
rm -rf /opt/course/e04
mkdir -p /opt/course/e04

# 2) etcdctl — 없으면 etcd 파드 이미지와 같은 버전을 설치 (예: registry.k8s.io/etcd:3.6.5-0 → 3.6.5)
command -v etcdctl || {
  VER=$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].spec.containers[0].image}' \
        | sed -E 's/.*:v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
  ARCH=$(dpkg --print-architecture)
  curl -fsSL https://github.com/etcd-io/etcd/releases/download/v$VER/etcd-v$VER-linux-$ARCH.tar.gz \
    | tar -xz -C /usr/local/bin --strip-components=1 etcd-v$VER-linux-$ARCH/etcdctl
}
etcdctl version

# 3) 클러스터 모양 확인 — 컨트롤 플레인 노드 수, etcd 파드
kubectl get nodes -l node-role.kubernetes.io/control-plane
kubectl -n kube-system get pods -l component=etcd -o wide
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

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

<details><summary>정리 명령 (방법 A)</summary>

```bash
rm -rf /opt/course/e04
```

</details>

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

---

Solution → **[solution.md](solution.md)**
