# q17 — Service traffic broken by kube-proxy

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` → `ssh worker01`, then `sudo -i` |
| Target time | 8 min |

## Setup — 사전 환경 설정

이 문제는 **클러스터를 일부러 고장 낸 상태에서** 시작한다. `k8s-c1` 에서 아래 스크립트를 실행한다(노드에 ssh 할 필요 없음). 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 kube-proxy 를 원래대로 돌려놓는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q17_kubeproxy_service_networking
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh              # 환경 만들기 (문제 노드: worker01)
bash cleanup.sh            # 실습 후 정리
bash setup.sh worker02     # 노드 이름이 다르면 인자로 준다 (cleanup.sh 도 같은 인자)
```

설정 직후 `app` 에는 Deployment `web`(nginx 3개), Service `web`(ClusterIP 80), Service `web-np`(NodePort)가 있고, `worker01` 에 테스트용 파드 `client`(busybox)가 떠 있다. `kubectl -n app exec client -- wget -qO- -T 3 http://<파드IP>` 는 응답하지만 ClusterIP 와 서비스 이름으로는 응답이 없다. 다른 노드의 파드에서는 정상이다.
busybox 에는 `curl` 이 없으므로 문제의 `curl` 은 `wget -qO- -T 3` 으로 바꿔 쓴다. kube-proxy DaemonSet 을 쓰는 클러스터가 필요하다(Cilium 의 kube-proxy 대체 모드에서는 재현되지 않는다). `app` 네임스페이스는 다른 문제도 쓰므로 setup·cleanup 은 이 문제가 만든 리소스만 지우고, 다른 문제의 NetworkPolicy 가 남아 있으면 멈춘다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

`worker01` 을 뺀 모든 노드에 `kube-proxy=enabled` 라벨을 달고 kube-proxy DaemonSet 에 `nodeSelector: kube-proxy=enabled` 를 넣어 `worker01` 의 kube-proxy 파드를 없앤다. 그다음 재부팅을 흉내 내려고 `worker01` 에 hostNetwork·privileged 파드(`kube-system/c17-reboot-sim`)를 한 번 띄워 `kube-proxy --cleanup` 으로 그 노드의 Service 룰(iptables·nftables·IPVS)을 지우고, 끝나면 그 파드도 지운다. `cleanup.sh` 는 DaemonSet 의 `kube-proxy` 셀렉터와 노드 라벨을 지우고, `worker01` 의 kube-proxy 가 다시 Ready 가 될 때까지 기다린다(시작하면서 룰을 전부 다시 쓴다).

</details>

## Task

`worker01` was rebooted this morning after kernel maintenance. Since then, in namespace
`app`, Service `web` (ClusterIP, port 80) still has 3 healthy endpoints, and from a pod
**on `worker01`** `curl http://<pod-ip>:80` works for every backend pod, but
`curl http://web.app.svc.cluster.local` and `curl http://<cluster-ip>:80` both hang.
NodePort Service `web-np` is unreachable through `worker01`'s IP. Pods on other nodes are
not affected.

1. Show that neither CoreDNS nor the Service's endpoints are the cause — one command each.
2. Identify the component responsible for ClusterIP translation and check its state on
   `worker01`.
3. Inspect the node's NAT rules to show the Service chains are missing.
4. Find and fix the root cause. Do not recreate the Service.
5. Verify ClusterIP and NodePort both work again.

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

[↑ 문항 목록](../README.md) · [← q16](../q16_node_disk_pressure_eviction/question.md)
