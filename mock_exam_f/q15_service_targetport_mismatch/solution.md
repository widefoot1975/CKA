# q15 — Endpoints exist but connections are refused · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `shop` 의 Deployment `payments` 는 `Running` 이고 `Ready` 인 파드 2개(image `nginx:1.27`,
라벨 `app=payments`)를 실행한다. Service `payments`(포트 `80`)는 그 파드들을 선택하고 엔드포인트도 있지만,
Service 로 가는 모든 요청이 `connection refused` 로 실패한다.

1. Service 에 엔드포인트가 있는데도 요청이 거부되는 이유를 찾는다.
2. Service `payments` 를 고친다. Deployment 는 바꾸지 않는다.
3. `payments` 의 EndpointSlice 가 이제 파드가 실제로 듣는 포트를 보여 주는지, 그리고 네임스페이스 `shop` 의
   임시 `busybox:1.36` 파드에서 `wget -qO- http://payments` 가 nginx 환영 페이지를 돌려주는지 확인한다.

## 모범 풀이

**1) 엔드포인트의 "주소"가 아니라 "포트"를 봅니다**

```bash
kubectl -n shop get endpointslice -l kubernetes.io/service-name=payments
# NAME             ADDRESSTYPE   PORTS   ENDPOINTS              AGE
# payments-x7k2p   IPv4          8080    10.0.1.14,10.0.2.9     10m      ← 8080?
kubectl -n shop get svc payments -o jsonpath='{.spec.ports[0].port} -> {.spec.ports[0].targetPort}{"\n"}'
# 80 -> 8080
```

파드 IP(ENDPOINTS 중 하나)로 두 포트를 직접 찔러 보면 원인이 확정됩니다.

```bash
kubectl -n shop run tmp --rm -it --image=busybox:1.36 --restart=Never -- \
  sh -c 'wget -qO- -T 2 http://10.0.1.14:8080; wget -qO- -T 2 http://10.0.1.14:80 | grep title'
# wget: can't connect to remote host (10.0.1.14): Connection refused
# <title>Welcome to nginx!</title>
```

**2) targetPort 를 파드가 듣는 80 으로**

```bash
kubectl -n shop patch svc payments --type=json \
  -p '[{"op":"replace","path":"/spec/ports/0/targetPort","value":80}]'
# 또는 kubectl -n shop edit svc payments  →  targetPort: 80
```

**핵심 — 엔드포인트가 있다는 것은 "selector 가 Ready 파드를 찾았다"는 뜻일 뿐입니다.** EndpointSlice 는
selector 와 파드의 Ready 상태로만 만들어지고, 그 포트에서 실제로 무언가 듣고 있는지는 확인하지 않습니다.
kube-proxy 는 ClusterIP:80 으로 온 요청을 `파드IP:targetPort`(여기서는 8080)로 보내는데, nginx 는 80 에서만
듣고 있어 파드가 연결을 거부했습니다.

| 필드 | 위치 | 뜻 |
|---|---|---|
| `port` | Service | 클라이언트가 접속하는 Service 포트 |
| `targetPort` | Service | 트래픽을 넘길 **파드의** 포트. EndpointSlice 의 PORTS 에 이 값이 나온다 |
| `containerPort` | Pod | 정보용 선언. 실제로 어느 포트를 여는지는 프로세스(nginx: 80)가 정한다 |

## 검증

```bash
kubectl -n shop get endpointslice -l kubernetes.io/service-name=payments
# payments-x7k2p   IPv4   80   10.0.1.14,10.0.2.9   ...
kubectl -n shop run tmp --rm -it --image=busybox:1.36 --restart=Never -- wget -qO- -T 2 http://payments
# <!DOCTYPE html> ... <title>Welcome to nginx!</title> ...
kubectl -n shop get svc payments -o jsonpath='{.spec.ports[0].port} -> {.spec.ports[0].targetPort}{"\n"}'
# 80 -> 80
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 엔드포인트가 있음 ≠ 포트가 맞음. EndpointSlice 의 PORTS(= targetPort)와 파드가 실제로 듣는 포트를 비교한다.
- **헷갈리는 지점**: `connection refused` 만으로는 원인을 가를 수 없습니다. 엔드포인트가 **하나도 없을** 때도 kube-proxy 가 요청을 거부(REJECT)해서 같은 오류가 납니다. 그래서 EndpointSlice 를 먼저 보고, ENDPOINTS 가 비었으면 selector·Ready 를, 채워져 있으면 PORTS 를 봅니다.

## 참고 문서

- 검색어: `debug services`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/
- https://kubernetes.io/docs/concepts/services-networking/service/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
