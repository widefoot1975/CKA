# q17 — CoreDNS name resolution failure · 풀이

← 문제: **[question.md](question.md)**

## 모범 풀이

ClusterIP로는 되고 이름으로는 안 된다면 **네트워크가 아니라 DNS 문제**로 범위가 이미 좁혀졌습니다.

```bash
# 1) 테스트 파드에서 증상 재현
kubectl run dnstest --rm -it --image=busybox:1.36 --restart=Never -- \
  nslookup kubernetes.default

# 2) 파드가 어느 DNS 서버를 보는지
kubectl run dnstest --rm -it --image=busybox:1.36 --restart=Never -- \
  cat /etc/resolv.conf
# nameserver 는 kube-dns Service 의 ClusterIP 여야 함 (보통 10.96.0.10)

# 3) CoreDNS 자체
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n kube-system logs -l k8s-app=kube-dns --tail=50
kubectl -n kube-system get svc kube-dns
kubectl -n kube-system get endpoints kube-dns      # 비어 있으면 파드가 Ready 가 아님
```

**원인별 조치**

| 증상 | 원인 | 조치 |
|---|---|---|
| CoreDNS 파드 0개 | Deployment replicas 0 | `kubectl -n kube-system scale deploy coredns --replicas=2` |
| CrashLoopBackOff | Corefile 문법 오류 | ConfigMap `coredns` 수정 |
| 로그에 `loop detected` | 상위 DNS가 자신을 가리킴 | Corefile의 `forward . /etc/resolv.conf` 를 실제 DNS(예: `8.8.8.8`)로 |
| `endpoints kube-dns` 비어 있음 | 파드 Ready 아님 | 파드 로그 확인 |
| resolv.conf 의 nameserver 가 다름 | kubelet `clusterDNS` 설정 | `/var/lib/kubelet/config.yaml` 수정 후 kubelet 재시작 |

```bash
# Corefile 확인 / 수정
kubectl -n kube-system get cm coredns -o yaml
kubectl -n kube-system edit cm coredns

# ConfigMap 변경은 CoreDNS 를 재시작해야 반영됨
kubectl -n kube-system rollout restart deploy coredns
kubectl -n kube-system rollout status deploy coredns
```

`kube-dns` 라는 **Service 이름은 그대로 유지**되고 그 뒤의 파드만 CoreDNS로 바뀌었습니다. 그래서 Service는 `kube-dns`, Deployment는 `coredns` 입니다 — 이름이 어긋나 보여도 정상입니다.

## 검증

```bash
kubectl -n kube-system get pods -l k8s-app=kube-dns       # Running 1/1
kubectl -n kube-system get endpoints kube-dns             # IP 있음

kubectl run dnstest --rm -it --image=busybox:1.36 --restart=Never -- \
  nslookup kubernetes.default
# Server: 10.96.0.10
# Name:   kubernetes.default.svc.cluster.local

kubectl run dnstest --rm -it --image=busybox:1.36 --restart=Never -- \
  nslookup catalog-svc.shop.svc.cluster.local
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Service는 `kube-dns`, Deployment/ConfigMap은 `coredns`.
- **헷갈리는 지점**: ConfigMap을 고쳤다고 바로 적용되지 않습니다. `rollout restart` 가 필요합니다.

## 참고 문서

- 검색어: `debug dns resolution`
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
