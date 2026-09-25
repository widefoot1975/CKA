# q09 — Publish a container port with a NodePort Service · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`spline` 네임스페이스에 Deployment `front-end`(image `nginx:1.27`, 컨테이너 이름 `nginx`)가 있다. 파드
템플릿에는 컨테이너 포트가 하나도 선언되어 있지 않다.

1. Deployment를 수정해 컨테이너 `nginx` 가 containerPort `80`, 이름 `http`, protocol `TCP` 를 선언하게 한다.
2. `spline` 에 `front-end` 파드를 선택하는 `NodePort` 타입 Service `front-end-svc` 를 만든다. port `80` 을
   targetPort `80` 으로 연결하고 nodePort는 `30080` 으로 고정한다.
3. Service에 endpoint가 있는지, `http://<노드 IP>:30080` 이 nginx 환영 페이지를 돌려주는지 확인한다.

## 모범 풀이

**1) 컨테이너 포트 선언** — `kubectl -n spline edit deploy front-end` 로 컨테이너에 `ports` 를 추가합니다.

```yaml
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:                    # 추가
        - name: http
          containerPort: 80
          protocol: TCP
```

한 줄로 하려면 patch를 씁니다(컨테이너는 `name` 으로 병합됩니다). 템플릿이 바뀌므로 파드가 새로 뜹니다.

```bash
kubectl -n spline patch deploy front-end -p \
  '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","ports":[{"name":"http","containerPort":80,"protocol":"TCP"}]}]}}}}'
kubectl -n spline rollout status deploy front-end
```

`containerPort` 선언은 대부분 **정보용**입니다. 선언이 없어도 컨테이너가 `0.0.0.0:80` 에서 듣고 있으면
Service는 트래픽을 보낼 수 있습니다. 선언의 실익은 문서화와, 이름을 붙였을 때 `targetPort: http` 처럼
**이름으로 참조**할 수 있다는 점입니다.

**2) NodePort Service — 고정 nodePort는 yaml로**

`kubectl expose` 에는 nodePort를 지정하는 플래그가 없습니다. 뼈대를 뽑아 한 줄을 더합니다.

```bash
kubectl -n spline expose deploy front-end --name=front-end-svc --type=NodePort \
  --port=80 --target-port=80 --dry-run=client -o yaml > svc.yaml
vi svc.yaml                   # ports 항목에 nodePort: 30080 추가
kubectl -n spline apply -f svc.yaml
```

```yaml
spec:
  type: NodePort
  selector:
    app: front-end            # expose 가 Deployment 의 selector 를 복사한다
  ports:
  - port: 80                  # Service(ClusterIP) 가 받는 포트
    targetPort: 80            # 파드로 보내는 포트 (http 라고 써도 된다)
    nodePort: 30080           # 모든 노드 IP 에 열리는 포트 (기본 범위 30000-32767)
    protocol: TCP
```

`kubectl create service nodeport front-end-svc --tcp=80:80 --node-port=30080` 도 되지만, 이 명령은 selector를
`app=front-end-svc`(Service 이름)로 만들어 파드를 못 찾습니다. 쓴다면 이어서
`kubectl -n spline set selector svc front-end-svc app=front-end` 로 고칩니다.

## 검증

```bash
kubectl -n spline get svc front-end-svc              # TYPE NodePort, PORT(S) 80:30080/TCP
kubectl -n spline get endpointslice -l kubernetes.io/service-name=front-end-svc
# NAME                  ADDRESSTYPE   PORTS   ENDPOINTS                 AGE
# front-end-svc-7xk2d   IPv4          80      10.244.1.12,10.244.2.7    20s
kubectl get nodes -o wide                             # INTERNAL-IP 확인
curl -s http://192.168.100.21:30080 | grep '<title>'  # <title>Welcome to nginx!</title>
```

`localhost:30080` 이 아니라 **노드 IP**로 테스트합니다. kube-proxy nftables 모드(v1.33 GA)는 localhost로
들어오는 NodePort를 지원하지 않아서, 설정은 맞는데 `curl localhost` 만 실패하는 일이 생깁니다.

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `port`(Service) → `targetPort`(파드) → `nodePort`(노드). 고정 nodePort는 `expose --dry-run=client -o yaml` 로 뽑아 한 줄 추가한다.
- **헷갈리는 지점**: EndpointSlice가 비어 있으면 포트가 아니라 selector 문제입니다. 반대로 endpoint는 있는데 접속이 거부되면 `targetPort` 가 실제로 듣고 있는 포트와 다른 것입니다. 이미 쓰이는 nodePort를 지정하면 `provided port is already allocated` 로 거부됩니다.

## 참고 문서

- 검색어: `service nodeport`
- https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
- https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
