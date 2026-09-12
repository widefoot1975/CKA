# q15 — A Service with no Endpoints · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`shop` 네임스페이스의 Service `catalog-svc` 로 보낸 요청에 응답이 없다. 파드는 모두 `Running` 이다.

1. `kubectl get endpoints catalog-svc` 가 비어 있는 이유를 찾는다.
2. 파드나 Deployment를 **다시 만들지 않고** 고친다.
3. Service 이름으로 접근되는지 확인한다.

## 모범 풀이

Endpoints가 비어 있다는 것은 **Service의 selector가 어떤 파드도 고르지 못했다**는 뜻입니다. 원인은 거의 셋 중 하나입니다.

```bash
# 1) Service 의 selector 와 파드의 label 을 나란히 비교
kubectl -n shop get svc catalog-svc -o jsonpath='{.spec.selector}'; echo
kubectl -n shop get pods --show-labels

# 2) 포트도 확인 — targetPort 가 컨테이너 포트와 맞는지
kubectl -n shop get svc catalog-svc -o jsonpath='{.spec.ports[*]}'; echo
kubectl -n shop get pods -o jsonpath='{.items[0].spec.containers[0].ports}'; echo
```

**원인별 조치**

| 원인 | 확인 방법 | 조치 |
|---|---|---|
| selector 키/값 오타 | 위 1번에서 불일치 | Service의 selector 수정 |
| `targetPort` 불일치 | 위 2번 | Service의 targetPort 수정 |
| 파드가 Ready가 아님 | `kubectl get pods` 의 READY 열 | readinessProbe 수정 |
| 네임스페이스 불일치 | Service와 파드가 다른 ns | 같은 ns로 |

```bash
# selector 수정 (파드를 건드리지 않고 Service 만)
kubectl -n shop patch svc catalog-svc -p '{"spec":{"selector":{"app":"catalog"}}}'

# targetPort 수정
kubectl -n shop patch svc catalog-svc -p '{"spec":{"ports":[{"port":8080,"targetPort":80,"protocol":"TCP"}]}}'
```

**Ready가 아닌 파드는 Endpoints에 들어가지 않습니다.** `Running` 이지만 `READY 0/1` 이면 readinessProbe가 실패하는 것이고, 이 경우 selector는 맞아도 Endpoints가 빕니다. `Running` 만 보고 정상이라 판단하면 이 케이스를 놓칩니다.

## 검증

```bash
kubectl -n shop get endpoints catalog-svc         # ENDPOINTS 에 파드 IP 들
kubectl -n shop get pods                          # READY 가 1/1
kubectl -n shop describe svc catalog-svc | grep -E 'Selector|Endpoints|TargetPort'

kubectl -n shop run tmp --rm -it --image=busybox:1.36 --restart=Never -- \
  wget -qO- catalog-svc:8080 | head -3
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Endpoints가 비면 selector 또는 readiness. 이 둘만 보면 대부분 끝납니다.
- **헷갈리는 지점**: `kubectl get endpoints` 대신 `kubectl get endpointslice` 로 봐야 하는 경우도 있습니다 (둘 다 확인하면 안전).

## 참고 문서

- 검색어: `debug service`
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
