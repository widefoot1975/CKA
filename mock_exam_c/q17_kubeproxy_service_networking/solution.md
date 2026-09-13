# q17 — Service traffic broken by kube-proxy · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `app` 의 Service `web` (ClusterIP, 포트 80)에 정상 엔드포인트 3개가 있다. 파드에서
`curl http://<파드IP>:80` 은 모든 백엔드 파드에 대해 동작하지만
`curl http://web.app.svc.cluster.local` 과 `curl http://<ClusterIP>:80` 은 둘 다 멈춘다.
NodePort Service `web-np` 도 외부에서 접근되지 않는다. `worker01` 의 파드만 영향을 받는다.

1. DNS와 엔드포인트가 원인이 아님을 배제한다 — 그것을 증명하는 두 명령을 보인다.
2. ClusterIP 변환을 담당하는 컴포넌트를 특정하고 `worker01` 에서 상태를 확인한다.
3. 노드의 NAT 룰을 조사해 Service 체인이 없음을 보인다.
4. 근본 원인을 찾아 고친다. Service를 재생성하지 않는다.
5. ClusterIP와 NodePort가 모두 다시 동작하는지 확인한다.

## 모범 풀이

**1) DNS와 엔드포인트 배제**

```bash
kubectl -n app get ep web
# ENDPOINTS  10.244.1.5:80,10.244.2.7:80,10.244.2.8:80     ← 엔드포인트는 정상

kubectl -n app run dbg --rm -it --image=busybox:1.36 --restart=Never -- \
  nslookup web.app.svc.cluster.local
# Address: 10.96.88.21     ← ClusterIP 로 해석은 된다
```

이름이 ClusterIP로 해석되고 엔드포인트도 채워져 있는데 ClusterIP에 연결이 안 되면, 남은 계층은
**ClusterIP → 파드 IP 변환**뿐입니다. 파드 IP 직접 접속이 되므로 CNI와 파드 간 라우팅도 정상입니다.
DNS 문제라면 이름 해석 자체가 실패하고, 엔드포인트 문제라면 `ep` 가 비어 있거나
`curl` 이 즉시 connection refused를 냅니다. 여기처럼 **멈추는(hang)** 것은 패킷이 어디로도 가지
못한다는 신호입니다.

**2) kube-proxy 상태**

ClusterIP는 실제 인터페이스가 없는 가상 IP입니다. 각 노드의 kube-proxy가 iptables(또는 IPVS)
룰을 심어 목적지를 파드 IP로 DNAT합니다. 그 룰이 없으면 패킷이 버려집니다.

```bash
kubectl -n kube-system get ds kube-proxy
# DESIRED 3  CURRENT 3  READY 2        ← 하나가 Ready 아님

kubectl -n kube-system get pods -l k8s-app=kube-proxy -o wide
# worker01 의 파드가 CrashLoopBackOff

kubectl -n kube-system logs -l k8s-app=kube-proxy --tail=30
kubectl -n kube-system describe pod <kube-proxy-worker01>
```

kube-proxy는 kube-system의 **DaemonSet**입니다. 노드마다 정확히 하나 떠 있어야 하고, 한 노드의
파드만 죽으면 그 노드의 파드들만 서비스에 접근하지 못하는 이 문제의 증상과 정확히 일치합니다.

| 로그·증상 | 원인 | 조치 |
|---|---|---|
| `open /var/lib/kube-proxy/config.conf: no such file` | ConfigMap `kube-proxy` 손상·삭제 | ConfigMap 복원 |
| `unable to load in-cluster configuration` / 401 | ServiceAccount·RBAC 문제 | `system:node-proxier` 바인딩 확인 |
| `can't set sysctl net/ipv4/conf/all/route_localnet` | 컨테이너가 privileged 아님 | DaemonSet의 securityContext |
| `Failed to execute iptables-restore` | 다른 프로세스가 iptables 점유, 또는 nft/legacy 혼용 | 노드에서 `iptables-save` 확인 |
| 파드는 Running인데 룰 없음 | `--proxy-mode` 값 오류, 잘못된 `hostnameOverride` | ConfigMap 확인 |
| 노드에서 `net.ipv4.ip_forward=0` | 포워딩 비활성 | `sysctl -w net.ipv4.ip_forward=1` |

**3) NAT 룰 확인** (worker01, root)

```bash
iptables -t nat -L KUBE-SERVICES -n | head -20
# 비어 있거나 체인 자체가 없다 (정상이면 서비스별 KUBE-SVC-xxxx 로 가는 줄이 보인다)

iptables -t nat -L -n | grep -c KUBE-SVC        # 0
iptables-save | grep 10.96.88.21                # 결과 없음
```

정상 노드와 비교하면 차이가 명확합니다. 정상이라면:

```
KUBE-SVC-XXXXXXXX  tcp -- 0.0.0.0/0  10.96.88.21  tcp dpt:80
```

IPVS 모드라면 `ipvsadm -Ln` 으로 확인하고 `grep mode /var/lib/kube-proxy/config.conf` 로
어느 모드인지 먼저 봅니다.

**4) 수정** — 이 문제에서는 ConfigMap 참조가 깨져 kube-proxy가 설정 파일을 읽지 못한 경우입니다.

```bash
kubectl -n kube-system get cm kube-proxy -o yaml | head -30
# config.conf 와 kubeconfig.conf 두 키가 있어야 한다

# ConfigMap이 정상인데 파드만 죽어 있으면 재시작으로 충분하다
kubectl -n kube-system rollout restart ds kube-proxy
kubectl -n kube-system rollout status ds kube-proxy

# ConfigMap이 없거나 손상되었으면 kubeadm으로 재생성한다 (컨트롤 플레인에서)
kubeadm init phase addon kube-proxy \
  --apiserver-advertise-address=<cp-ip> --pod-network-cidr=10.244.0.0/16
```

kube-proxy 파드가 다시 뜨면 시작 시 iptables 룰을 전부 다시 씁니다. 룰을 손으로 복구할 필요는
없습니다 — 오히려 손으로 넣은 룰은 다음 동기화에서 지워집니다.

## 검증

```bash
kubectl -n kube-system get ds kube-proxy
# DESIRED 3  CURRENT 3  READY 3  UP-TO-DATE 3
kubectl -n kube-system logs -l k8s-app=kube-proxy --tail=10 | grep -i error   # 없음

# worker01 에서
iptables -t nat -L KUBE-SERVICES -n | grep 10.96.88.21     # DNAT 룰 존재

CIP=$(kubectl -n app get svc web -o jsonpath='{.spec.clusterIP}')
kubectl -n app run v --rm -it --image=busybox:1.36 --restart=Never -- \
  wget -qO- --timeout=3 http://$CIP:80                     # HTML 응답

kubectl -n app run v2 --rm -it --image=busybox:1.36 --restart=Never -- \
  wget -qO- --timeout=3 http://web.app.svc.cluster.local

NP=$(kubectl -n app get svc web-np -o jsonpath='{.spec.ports[0].nodePort}')
curl -s --max-time 3 http://<worker01-ip>:$NP | head -3
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 파드 IP는 되고 ClusterIP만 안 되면 kube-proxy. 노드별로 다르면 그 노드의 kube-proxy 파드.
- **헷갈리는 지점**: 세 가지 실패가 겉보기에 비슷합니다. 이름 해석 실패 = DNS(q13),
  `ep` 가 비어 있음 = 셀렉터·readiness 문제, 이름과 엔드포인트는 정상인데 ClusterIP 연결 불가 =
  kube-proxy. 그리고 `curl` 이 **즉시 refused** 면 목적지가 응답한 것(엔드포인트는 도달)이고,
  **hang** 이면 패킷이 버려진 것(룰 없음·정책 차단)입니다. 이 두 반응의 차이로 절반을 걸러낼 수 있습니다.

## 참고 문서

- 검색어: `debug service`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/
- https://kubernetes.io/docs/reference/networking/virtual-ips/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
