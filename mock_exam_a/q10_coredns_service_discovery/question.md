# q10 — Service discovery with CoreDNS

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q10_coredns_service_discovery
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 1단계에서 namespace 와 Deployment·Service 를 직접 만드는 것부터 시작하므로, setup 은 이전 흔적을 지우고
nginx 와 DNS 디버그 이미지(`jessie-dnsutils`)를 받을 수 있는지, CoreDNS 가 동작하는지만 확인한다. CoreDNS 설정은 건드리지 않는다.
`mock_exam_b/q10` 도 `alpha`·`beta` namespace 를 쓰므로, setup 과 cleanup 은 이 문제가 만드는 `web`·`no-dns`·`dns` 만 지우고
namespace 는 그 안에 다른 리소스가 없을 때만 지운다. namespace 가 남아 있으면 1단계의 `kubectl create namespace` 는
`AlreadyExists` 로 끝나는데, 그대로 다음 명령을 이어 가면 된다.

## Task

Two namespaces expose a Service of the same name and clients keep reaching the wrong one.

1. Create namespaces `alpha` and `beta`. In each, create a Deployment `web` running
   `nginx:1.27` and a ClusterIP Service `web` on port 80.
2. Report which Deployment provides cluster DNS in `kube-system`, which Service fronts it,
   and which ConfigMap holds its Corefile.
3. From a debug pod in `alpha`, resolve `web`, `web.beta`, `web.beta.svc.cluster.local` and
   `web.beta.cluster.local`. Record which one fails.
4. Print that pod's `/etc/resolv.conf` and explain why a bare `web` resolves to `alpha`.
5. Create a Pod `no-dns` in `alpha` that does not use cluster DNS at all, and show that
   `web` no longer resolves inside it.
6. Write the FQDN a client uses to reach one specific pod behind a headless Service.

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

[↑ 문항 목록](../README.md) · [← q09](../q09_ingress_path_routing/question.md) · [q11 →](../q11_pv_pvc_static_provisioning/question.md)
