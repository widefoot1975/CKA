# q15 — A Service with no endpoints · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`shop` 네임스페이스의 Service `api-svc` 는 접속을 받지만 모든 클라이언트가 `connection refused` 를 받는다. Deployment `api` 의 파드 3개는 실행 중이다.

1. Service에 endpoint가 없음을 Endpoints 오브젝트로 한 번, EndpointSlice로 한 번 보인다.
2. Service 셀렉터와 파드에 실제로 붙어 있는 라벨을 비교한다.
3. 파드가 `Ready` 인지 보고한다.
4. Service의 `targetPort` 와 컨테이너가 실제로 듣는 포트를 비교한다.
5. endpoint 3개가 나타나도록 Service를 고친다. 파드의 라벨을 바꾸거나 재시작·재생성하지 않는다.
6. endpoint 목록이 비는 서로 독립적인 두 가지 이유를 한 줄로 적는다.

## 모범 풀이

**1) 증상 확정**

```bash
kubectl -n shop get svc api-svc
kubectl -n shop get endpoints api-svc     # api-svc   <none>   12m
kubectl -n shop get endpointslices -l kubernetes.io/service-name=api-svc
kubectl -n shop describe svc api-svc      # Selector 와 Endpoints: <none> 를 한 화면에서
```

**2) 셀렉터를 직접 조회해 봅니다.** 눈으로 대조하지 말고 셀렉터로 파드를 찾아보는 것이 가장 빠릅니다.

```bash
kubectl -n shop get svc api-svc -o jsonpath='{.spec.selector}{"\n"}'   # {"app":"api-server"}
kubectl -n shop get pods -l app=api-server   # No resources found ← 셀렉터가 아무것도 안 잡는다
kubectl -n shop get pods --show-labels       # api-xxxx  1/1  Running  ...  app=api,...
```

**3) Ready 여부와 4) 포트를 한 번에 봅니다**

```bash
kubectl -n shop get pods -o custom-columns='NAME:.metadata.name,READY:.status.containerStatuses[*].ready,PORT:.spec.containers[*].ports[*].containerPort'
kubectl -n shop get svc api-svc -o jsonpath='{.spec.ports[*]}{"\n"}'
```

**원인 표**

| 관찰 | 원인 | 조치 |
|---|---|---|
| `get pods -l <셀렉터>` 결과가 0개 | Service 셀렉터의 키/값 불일치 (오타, `app` vs `app.kubernetes.io/name`) | Service 셀렉터를 파드 라벨에 맞춘다 |
| 파드는 잡히는데 `READY` 가 `false` | readinessProbe 실패 — **Ready가 아닌 파드는 endpoint에 오르지 않는다** | 프로브 경로·포트 수정, 앱 기동 대기 |
| endpoint는 있는데 접속 거부 | `targetPort` 가 실제 리스닝 포트와 다름 | `targetPort` 수정 |
| Service에 셀렉터가 아예 없음 | `ExternalName` 이거나 Endpoints를 수동 관리하는 설계 | 의도 확인 후 셀렉터 추가 |
| 파드와 Service가 다른 네임스페이스 | 셀렉터는 같은 네임스페이스만 본다 | Service를 파드와 같은 네임스페이스에 만든다 |

**핵심은 Endpoints 오브젝트를 사람이 만들지 않는다는 점입니다.** endpoint controller가 Service의 셀렉터로 같은 네임스페이스의 파드를 찾아 자동으로 채웁니다. 그래서 비어 있다는 것은 언제나 "셀렉터가 파드를 못 찾았다" 또는 "찾은 파드가 Ready가 아니다" 둘 중 하나입니다. Endpoints를 직접 만들어 채우려 하면 컨트롤러가 다시 지웁니다.

**5) 수리 — 파드가 아니라 Service를 고칩니다**

```bash
kubectl -n shop edit svc api-svc
# spec.selector.app: api-server → api
# spec.ports[0].targetPort: 80 → 8080
```

patch로 하려면 포트 리스트는 `port` 를 키로 병합되므로 모든 필드를 함께 줘야 합니다.

```bash
kubectl -n shop patch svc api-svc -p \
  '{"spec":{"selector":{"app":"api"},"ports":[{"name":"http","port":80,"targetPort":8080,"protocol":"TCP"}]}}'
```

파드의 라벨을 Service에 맞춰 바꾸는 것은 답이 아닙니다. 파드 라벨은 Deployment의 `spec.selector` 와 묶여 있어서 임의로 바꾸면 ReplicaSet이 그 파드를 자기 것으로 인식하지 못해 여분의 파드를 새로 만듭니다.

**6) 두 가지 이유**: 셀렉터가 어떤 파드와도 매칭되지 않는 경우, 그리고 매칭된 파드가 `Ready` 가 아닌 경우.

Ready가 아닌 파드는 사라지는 게 아니라 **not-ready로 분류**됩니다. 이 차이를 보면 두 원인을 구분할 수 있습니다.

```bash
kubectl -n shop get endpoints api-svc -o yaml | grep -A5 notReadyAddresses   # 레거시 쪽
kubectl -n shop get endpointslices -l kubernetes.io/service-name=api-svc -o yaml \
  | grep -B2 -A4 conditions        # EndpointSlice: 주소는 남고 conditions.ready 가 false 다
```

즉 `ENDPOINTS` 열이 `<none>` 인데 위 두 곳에 주소가 **있으면** readiness 문제이고, 아무 데도 없으면 셀렉터 문제입니다.

## 검증

```bash
kubectl -n shop get endpoints api-svc
# api-svc   10.244.1.5:8080,10.244.1.6:8080,10.244.2.4:8080
kubectl -n shop get endpointslices -l kubernetes.io/service-name=api-svc -o wide
kubectl -n shop describe svc api-svc | grep -i endpoints
kubectl -n shop get pods -l app=api            # 3개가 잡혀야 한다
kubectl -n shop run tmp --rm -it --image=busybox:1.36 --restart=Never -- \
  wget -qO- api-svc:80 | head -3
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Endpoints가 비었으면 원인은 두 개뿐이다 — 셀렉터가 파드를 못 찾음, 또는 찾은 파드가 Ready가 아님. Service를 고치고 파드는 건드리지 않는다.
- **헷갈리는 지점**: `kubectl get pods -l app=api` 로 확인하지 않고 `--show-labels` 출력을 눈으로 대조하다 `app.kubernetes.io/name` 과 `app` 같은 유사 라벨을 놓치는 것. 그리고 endpoint가 정상으로 채워졌는데도 접속이 안 되면 그때부터는 `targetPort` 와 컨테이너 리스닝 포트의 불일치를 봐야 합니다 — endpoint 유무와 포트 불일치는 별개 문제입니다.

## 참고 문서

- 검색어: `debug service`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
