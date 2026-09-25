# q10 — Point a Service at a named container port · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`api` 네임스페이스의 Deployment `backend` 는 이름이 `nginx` 인 컨테이너에서 `nginx:1.27` 을 실행하고,
이 컨테이너는 포트 80에서 대기한다. 컨테이너 spec에는 아직 포트가 하나도 선언되어 있지 않다.

1. Deployment `backend` 의 컨테이너 `nginx` 에 이름이 `http` 인 컨테이너 포트 `80`(protocol `TCP`)을
   추가한다.
2. `api` 네임스페이스에 ClusterIP Service `backend` 를 만든다. 포트 `8080` 에서 받고, 대상 컨테이너
   포트를 **이름** `http` 로 가리킨다.
3. Service의 EndpointSlice가 대상 포트를 `80` 으로 해석하는지, 임시 `busybox:1.36` 파드에서
   `http://backend.api:8080` 이 nginx 환영 페이지를 돌려주는지 확인한다.

## 모범 풀이

**1) 이름 붙은 컨테이너 포트**

```bash
kubectl -n api patch deploy backend --type=json -p='[
  {"op":"add","path":"/spec/template/spec/containers/0/ports",
   "value":[{"name":"http","containerPort":80,"protocol":"TCP"}]}]'
kubectl -n api rollout status deploy backend
```

`kubectl -n api edit deploy backend` 로 넣어도 같습니다.

```yaml
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
```

**2) Service** — `--target-port` 는 숫자뿐 아니라 포트 **이름**도 받습니다. `expose` 는 Deployment의
셀렉터를 그대로 가져오고 기본 타입이 ClusterIP입니다.

```bash
kubectl -n api expose deploy backend --name=backend --port=8080 --target-port=http
kubectl -n api get svc backend -o jsonpath='{.spec.ports[0]}{"\n"}'
# {"port":8080,"protocol":"TCP","targetPort":"http"}
```

**이름으로 가리키면 무엇이 좋은가** — Service는 `targetPort: http` 라는 이름만 알고, 실제 번호는
EndpointSlice 컨트롤러가 각 파드의 `ports[].name` 을 보고 채웁니다. 나중에 컨테이너 포트가 8081로
바뀌어도 이름만 `http` 로 유지하면 Service는 손댈 필요가 없고, 번호가 다른 두 버전의 파드가 섞여 있어도
각자 맞는 번호로 연결됩니다. 대신 **파드 spec에 그 이름이 선언되어 있어야** 합니다 — 1단계가 필요한
이유입니다. 숫자 `targetPort` 는 `containerPort` 선언이 없어도 동작하지만, 이름은 선언이 없으면 해석할
수 없습니다.

## 검증

```bash
kubectl -n api get endpointslice -l kubernetes.io/service-name=backend
# NAME            ADDRESSTYPE   PORTS   ENDPOINTS     AGE
# backend-7xk2d   IPv4          80      10.244.1.12   20s      ← 8080 이 아니라 해석된 번호 80
kubectl -n api run tmp --rm -it --restart=Never --image=busybox:1.36 -- \
  wget -qO- http://backend.api:8080
# <!DOCTYPE html> ... <title>Welcome to nginx!</title> ...
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `targetPort` 에 이름을 쓰면 번호는 파드의 `ports[].name` 으로 결정된다. EndpointSlice의 PORTS에는 해석된 실제 번호(80)가 보인다.
- **헷갈리는 지점**: Service의 `port`(8080, 클라이언트가 접속하는 번호)와 `targetPort`(파드 쪽 번호나 이름)는 다릅니다. 파드에 그 이름의 포트가 없으면 에러 없이 그 파드로 트래픽이 가지 않으므로, 이름 오타(`htttp`)는 EndpointSlice의 PORTS부터 확인합니다.

## 참고 문서

- 검색어: `service port definitions`
- https://kubernetes.io/docs/concepts/services-networking/service/
- https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
