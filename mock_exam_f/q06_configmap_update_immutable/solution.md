# q06 — Update configuration and lock it · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `web` 의 Deployment `api`(image `nginx:1.27`)는 `envFrom` 으로 ConfigMap `app-config` 의 모든
키를 환경 변수로 읽는다. ConfigMap 에는 현재 `LOG_LEVEL=debug` 가 들어 있다.

1. ConfigMap `app-config` 의 `LOG_LEVEL` 을 `info` 로 바꾼다.
2. ConfigMap `app-config` 를 immutable 로 만들어 더 이상 데이터를 바꿀 수 없게 한다.
3. Deployment 를 지우지 않고 `api` 의 파드들이 새 값을 쓰게 만들고, `kubectl exec` 로 실행 중인 파드에
   `LOG_LEVEL=info` 가 설정되어 있는지 확인한다.

## 모범 풀이

```bash
kubectl -n web get deploy api -o yaml | grep -A2 envFrom
#       - envFrom:
#         - configMapRef:
#             name: app-config

kubectl -n web patch configmap app-config -p '{"data":{"LOG_LEVEL":"info"}}'    # 1) 값 변경
kubectl -n web patch configmap app-config -p '{"immutable":true}'               # 2) 잠금
kubectl -n web rollout restart deploy api                                       # 3) 파드 재생성
kubectl -n web rollout status deploy api
```

`kubectl edit` 으로 한 번에 해도 됩니다. `immutable` 은 `data` 와 같은 최상위 필드입니다(ConfigMap 에는
`spec` 이 없습니다).

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: web
data:
  LOG_LEVEL: info
immutable: true
```

**핵심 1 — 환경 변수는 컨테이너가 시작될 때 한 번만 채워집니다.** ConfigMap 을 바꿔도 실행 중인
컨테이너의 환경 변수는 그대로입니다. 새 값을 보려면 컨테이너가 새로 시작되어야 하고,
`kubectl rollout restart` 는 파드 템플릿에 `kubectl.kubernetes.io/restartedAt` 어노테이션을 넣어 새
ReplicaSet 으로 롤링 교체합니다. (볼륨으로 마운트한 ConfigMap 파일은 kubelet 이 잠시 뒤 갱신하지만,
`envFrom`/`env` 는 절대 갱신되지 않습니다.)

**핵심 2 — immutable 은 되돌릴 수 없습니다.** 한 번 `immutable: true` 가 되면 `data` 를 바꿀 수도,
`immutable` 을 `false` 로 되돌릴 수도 없습니다. 다시 바꾸려면 ConfigMap 을 지우고 새로 만든 뒤 파드를
재시작해야 합니다. 대신 kubelet 이 immutable ConfigMap 은 감시(watch)하지 않으므로 API server 부하가
줄어듭니다.

## 검증

```bash
kubectl -n web get cm app-config -o jsonpath='{.immutable} {.data.LOG_LEVEL}{"\n"}'   # true info
kubectl -n web patch cm app-config -p '{"data":{"LOG_LEVEL":"warn"}}'
# The ConfigMap "app-config" is invalid: data: Forbidden: field is immutable when `immutable` is set
kubectl -n web get pods                                  # AGE 가 방금인 새 파드들
kubectl -n web exec deploy/api -- env | grep LOG_LEVEL   # LOG_LEVEL=info
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: ConfigMap 값을 바꾼 뒤 환경 변수로 쓰는 파드는 `kubectl rollout restart` 해야 새 값을 본다. `immutable: true` 는 삭제·재생성 말고는 풀 수 없다.
- **헷갈리는 지점**: 순서가 중요합니다. 값을 바꾸기 **전에** immutable 로 만들면 1번을 할 수 없어 지우고 다시 만들어야 합니다. 그리고 `rollout restart` 없이 확인하면 옛 파드가 여전히 `LOG_LEVEL=debug` 를 보여 줘서 "patch 가 안 먹었다"고 오해하기 쉽습니다.

## 참고 문서

- 검색어: `configmap immutable`
- https://kubernetes.io/docs/concepts/configuration/configmap/#configmap-immutable
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
