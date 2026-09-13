# q08 — Service types and endpoint inspection · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`shop` 네임스페이스의 같은 파드 집합을 네 가지 방식으로 접근할 수 있게 만들어야 한다.

1. `shop` 에 `nginx:1.27` 3 레플리카, 컨테이너 포트 80인 Deployment `api` 를 만든다.
2. 포트 8080에서 컨테이너 포트 80으로 넘기는 ClusterIP Service `api-clusterip` 을 만든다.
3. 서비스 포트 8080, 타깃 포트 80, 노드 포트 31080 고정인 NodePort Service `api-nodeport` 을 만든다.
4. 같은 파드를 대상으로 포트 8080인 headless Service `api-headless` 를 만든다.
5. 포트 80인 LoadBalancer Service `api-lb` 를 만들고 `EXTERNAL-IP` 를 기록한다.
6. `api-clusterip` 을 받치는 파드 IP 3개를 Endpoints로 한 번, EndpointSlice로 한 번 조회한다.
7. 임시 파드에서 `api-clusterip` 에, 노드에서 `api-nodeport` 에 접속하고, `api-lb` 의 `EXTERNAL-IP` 가 무엇으로 보이는지와 그 이유를 한 줄로 적는다.

## 모범 풀이

```bash
kubectl create namespace shop
kubectl -n shop create deploy api --image=nginx:1.27 --replicas=3 --port=80

kubectl -n shop expose deploy api --name=api-clusterip --port=8080 --target-port=80
kubectl -n shop expose deploy api --name=api-lb --type=LoadBalancer --port=80 --target-port=80
```

`kubectl create deploy` 는 파드에 `app=api` 라벨을 붙이고 `expose` 는 그 라벨을 셀렉터로 가져옵니다.

NodePort 번호를 고정하려면 `expose` 만으로는 안 되므로 yaml이나 patch가 필요합니다.

```bash
kubectl -n shop expose deploy api --name=api-nodeport --type=NodePort --port=8080 --target-port=80
kubectl -n shop patch svc api-nodeport -p \
  '{"spec":{"ports":[{"port":8080,"targetPort":80,"nodePort":31080,"protocol":"TCP"}]}}'
```

headless는 `clusterIP: None` 이라 명령형으로 만들 수 없습니다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-headless
  namespace: shop
spec:
  clusterIP: None
  selector:
    app: api
  ports:
  - port: 8080
    targetPort: 80
```

**세 포트가 서로 다른 층입니다.**

| 필드 | 누가 쓰는 포트 | 범위 |
|---|---|---|
| `port` | Service 자신 — 클러스터 안에서 `svc:port` 로 접속 | 임의 |
| `targetPort` | 컨테이너가 실제로 듣는 포트 | 컨테이너가 정함 |
| `nodePort` | 모든 노드의 IP에서 열리는 포트 | **30000-32767** |

`targetPort` 를 생략하면 `port` 와 같은 값이 됩니다. 그래서 `--port=8080` 만 주고 `--target-port` 를 빼면 8080으로 nginx에 붙으려 하다 연결이 거부됩니다. NodePort 범위 밖의 번호를 주면 API가 거부합니다.

**headless Service**는 ClusterIP를 할당하지 않으므로 kube-proxy가 로드밸런싱하지 않고, DNS가 서비스 이름을 파드 IP 목록(A 레코드 여러 개)으로 직접 돌려줍니다. StatefulSet에서 개별 파드를 지목해야 할 때 씁니다.

**LoadBalancer의 `EXTERNAL-IP` 는 `<pending>` 으로 남습니다.** LoadBalancer 타입은 클라우드 컨트롤러 매니저(또는 MetalLB 같은 온프레미스 구현)가 외부 LB를 만들어 주소를 채워 넣어야 완성됩니다. kubeadm으로 올린 베어메탈 클러스터에는 그 구현체가 없으니 아무도 채워 주지 않습니다. 다만 LoadBalancer는 NodePort를 포함하므로 노드 포트로는 접근됩니다.

## 검증

```bash
kubectl -n shop get svc
# api-clusterip  ClusterIP   10.96.x.x   <none>   8080/TCP
# api-nodeport   NodePort    10.96.x.x   <none>   8080:31080/TCP
# api-headless   ClusterIP   None        <none>   8080/TCP
# api-lb         LoadBalancer 10.96.x.x  <pending> 80:3xxxx/TCP

kubectl -n shop get endpoints api-clusterip
# api-clusterip   10.244.1.5:80,10.244.1.6:80,10.244.2.4:80

kubectl -n shop get endpointslices -l kubernetes.io/service-name=api-clusterip -o wide
kubectl -n shop get endpointslices -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.endpoints[*].addresses}{"\n"}{end}'

kubectl -n shop run tmp --rm -it --image=busybox:1.36 --restart=Never -- \
  wget -qO- api-clusterip:8080 | head -3

# 아무 노드에서
curl -s localhost:31080 | head -3

# headless는 IP 대신 파드 IP 목록이 돌아온다
kubectl -n shop run dns --rm -it --image=busybox:1.36 --restart=Never -- nslookup api-headless
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `port` 는 Service, `targetPort` 는 컨테이너, `nodePort` 는 노드(30000-32767). `targetPort` 를 빼면 `port` 값이 그대로 복사된다.
- **헷갈리는 지점**: `kubectl get endpoints` 와 `kubectl get endpointslices` 는 같은 정보를 다르게 보여줍니다. Endpoints API는 v1.33에서 deprecated되었고 실제 데이터 소스는 EndpointSlice입니다. `get endpoints` 는 아직 동작하지만 EndpointSlice 쪽을 보는 습관이 낫습니다. EndpointSlice를 라벨 없이 조회하면 네임스페이스의 모든 서비스 것이 나오므로 `-l kubernetes.io/service-name=<svc>` 로 걸러야 합니다.

## 참고 문서

- 검색어: `service publishing services service types`
- https://kubernetes.io/docs/concepts/services-networking/service/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
