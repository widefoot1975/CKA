# q13 — Cluster DNS resolution is failing · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터 전체의 파드가 어떤 이름도 해석하지 못한다. 모든 파드 내부에서
`curl http://backend.app.svc.cluster.local` 이 lookup 오류로 실패하지만
`curl http://10.244.2.14` (파드 IP)는 동작한다. `kubernetes.io` 같은 외부 이름도 실패한다.

1. 파드 내부에서 이것이 라우팅 실패가 아니라 DNS 실패임을 확인한다.
2. 어느 계층이 깨졌는지 판정한다: 파드의 리졸버 설정, `kube-dns` Service, CoreDNS 파드,
   또는 CoreDNS 설정.
3. 클러스터 내부 Service 이름과 외부 이름이 모두 해석되도록 고친다.
4. 근본 원인을 한 문장으로 `/opt/course/q13/cause.txt` 에 쓴다.
5. `kube-dns` Service를 삭제하지 말고, 어떤 파드의 `dnsPolicy` 도 바꾸지 않는다.

## 모범 풀이

**1) DNS 실패 확정** — IP는 되고 이름은 안 되면 DNS입니다. 파드 내부에서 확인합니다.

```bash
kubectl run dbg --rm -it --image=nicolaka/netshoot --restart=Never -- sh
cat /etc/resolv.conf
#   nameserver 10.96.0.10
#   search default.svc.cluster.local svc.cluster.local cluster.local
#   options ndots:5
nslookup kubernetes.default          # ;; connection timed out; no servers could be reached
nslookup kubernetes.default 10.96.0.10
```

`/etc/resolv.conf` 의 nameserver가 정상인데 응답이 없으면 파드 설정 문제는 아닙니다.

**2) 위에서 아래로 좁히기**

```bash
# 서비스와 엔드포인트
kubectl -n kube-system get svc kube-dns            # CLUSTER-IP 가 resolv.conf 의 값과 같은지
kubectl -n kube-system get ep kube-dns             # 비어 있으면 파드가 Ready 가 아니다

# CoreDNS 파드
kubectl -n kube-system get pods -l k8s-app=kube-dns -o wide
kubectl -n kube-system describe pod <coredns-xxx>
kubectl -n kube-system logs -l k8s-app=kube-dns --tail=50

# 설정
kubectl -n kube-system get cm coredns -o yaml
```

증상별 원인 표:

| 관찰 | 원인 | 조치 |
|---|---|---|
| `ep kube-dns` 가 `<none>` | CoreDNS 파드가 0개 또는 Ready 아님 | 아래 행들로 계속 |
| CoreDNS `Pending` | 컨트롤 플레인 테인트만 있는 클러스터에서 레플리카 배치 실패, 리소스 부족 | `describe pod` 의 Events, 노드 여유 확인 |
| CoreDNS `CrashLoopBackOff`, 로그에 `plugin/errors ... Corefile:N` | Corefile 문법 오류 | ConfigMap 수정 후 파드 재시작 |
| CoreDNS 로그에 `Loop ... detected` | upstream이 자기 자신을 가리킴 (`forward . /etc/resolv.conf` + 노드 resolv.conf가 127.0.0.53) | `forward . 8.8.8.8` 등 실제 upstream으로 |
| 파드 Running·Ready인데 무응답, resolv.conf의 IP ≠ svc ClusterIP | kubelet의 `clusterDNS` 불일치 | 아래 참조 |
| 내부만 되고 외부만 안 됨 | `forward` 블록 누락/오류 | Corefile의 `forward` 수정 |
| 전부 안 되고 `iptables` 에 KUBE-SVC 룰 없음 | kube-proxy 문제 | q17 참조 |

**3) 가장 흔한 실제 원인 — Corefile 손상**. `kubernetes` 또는 `forward` 플러그인 줄이 깨져
CoreDNS가 CrashLoop에 빠진 경우입니다.

```bash
kubectl -n kube-system edit cm coredns
```

정상 Corefile:

```
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf {
       max_concurrent 1000
    }
    cache 30
    loop
    reload
    loadbalance
}
```

`kubernetes cluster.local ...` 블록이 클러스터 내부 이름을, `forward . /etc/resolv.conf` 가
외부 이름을 담당합니다. 내부만 실패하면 앞쪽, 외부만 실패하면 뒤쪽입니다. 여기서는 둘 다
실패하므로 파드 자체가 살아 있지 않다는 신호입니다.

ConfigMap을 고쳐도 **CoreDNS는 자동 반영되지 않을 수 있습니다.** Corefile에 `reload` 플러그인이
있으면 약 30초 내에 다시 읽지만, CrashLoopBackOff 상태라면 프로세스가 살아 있지 않으므로
재시작해야 합니다.

```bash
kubectl -n kube-system rollout restart deploy coredns
kubectl -n kube-system rollout status deploy coredns
```

kubelet의 `clusterDNS` 가 실제 `kube-dns` ClusterIP와 다른 경우는 파드의 `resolv.conf` 를 보면
바로 드러납니다. 노드에서 고칩니다:

```bash
grep clusterDNS /var/lib/kubelet/config.yaml     # 10.96.0.10 이어야 한다
systemctl restart kubelet                        # 수정했다면
```

이미 뜬 파드의 `resolv.conf` 는 다시 쓰이지 않으므로 파드를 재생성해야 반영됩니다.

**4) 원인 기록**

```bash
mkdir -p /opt/course/q13
echo "coredns ConfigMap의 Corefile 문법 오류로 CoreDNS 파드가 CrashLoopBackOff에 빠져 kube-dns 엔드포인트가 비어 있었다." \
  > /opt/course/q13/cause.txt
```

## 검증

```bash
kubectl -n kube-system get pods -l k8s-app=kube-dns
# 2/2 Running, RESTARTS 증가 멈춤
kubectl -n kube-system get ep kube-dns
# ENDPOINTS 에 CoreDNS 파드 IP:53 두 개

kubectl run v --rm -it --image=busybox:1.36 --restart=Never -- \
  nslookup kubernetes.default.svc.cluster.local
# Address: 10.96.0.1        ← 내부 해석 성공

kubectl run v2 --rm -it --image=busybox:1.36 --restart=Never -- \
  nslookup kubernetes.io
# 공인 IP 응답            ← 외부 해석 성공

kubectl -n kube-system logs -l k8s-app=kube-dns --tail=20   # 에러 없음
cat /opt/course/q13/cause.txt
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 파드 IP는 되고 이름만 안 되면 DNS. 순서는 파드 `/etc/resolv.conf` → `ep kube-dns` → CoreDNS 파드 → Corefile.
- **헷갈리는 지점**: 서비스 이름은 `kube-dns` 인데 실행되는 파드는 CoreDNS입니다 (구버전 kube-dns와의
  호환을 위해 서비스 이름을 유지). 그래서 셀렉터도 `k8s-app=kube-dns` 이고 `k8s-app=coredns` 가
  아닙니다. 이걸 모르면 파드를 못 찾습니다. 또 내부 이름만 실패하는지 외부까지 실패하는지가
  Corefile의 어느 블록을 볼지 결정합니다 — 항상 둘 다 테스트해야 합니다.

## 참고 문서

- 검색어: `debugging DNS resolution`
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
- https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
