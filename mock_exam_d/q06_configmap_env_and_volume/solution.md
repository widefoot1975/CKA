# q06 — Inject a ConfigMap as an env var and a file · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`cfg` 네임스페이스가 있다. 애플리케이션은 설정 하나는 환경 변수로, 전체 설정은 파일로 받아야 한다.

1. `cfg` 에 키 `MODE=prod`, `COLOR=blue` 를 가진 ConfigMap `app-settings` 를 만든다.
2. `cfg` 에 파드 `settings-demo`(image `busybox:1.36`, command `sleep 3600`)를 만든다. 이 파드는
   - 키 `MODE` 의 값을 환경 변수 `APP_MODE` 로 받고,
   - ConfigMap 전체를 볼륨으로 `/etc/settings` 에 마운트한다.
3. 파드 안에서 `APP_MODE` 가 `prod` 이고 파일 `/etc/settings/COLOR` 의 내용이 `blue` 인지 확인한다.

## 모범 풀이

```bash
kubectl -n cfg create configmap app-settings --from-literal=MODE=prod --from-literal=COLOR=blue

kubectl -n cfg run settings-demo --image=busybox:1.36 \
  --dry-run=client -o yaml --command -- sleep 3600 > settings-demo.yaml
vi settings-demo.yaml      # env 와 volumeMounts / volumes 추가
kubectl -n cfg apply -f settings-demo.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: settings-demo
  namespace: cfg
spec:
  containers:
  - name: settings-demo
    image: busybox:1.36
    command: ["sleep", "3600"]
    env:
    - name: APP_MODE              # 컨테이너 안에서의 변수 이름
      valueFrom:
        configMapKeyRef:
          name: app-settings
          key: MODE               # ConfigMap 의 키
    volumeMounts:
    - name: settings
      mountPath: /etc/settings
  volumes:
  - name: settings
    configMap:
      name: app-settings          # 키 하나가 파일 하나가 된다 (MODE, COLOR)
```

**env와 볼륨은 갱신 방식이 다릅니다 — 이 문제의 핵심입니다.**

| 방식 | 값이 들어가는 시점 | ConfigMap을 바꾸면 |
|---|---|---|
| `env` / `envFrom` | 컨테이너가 시작될 때 한 번 | **바뀌지 않음** — 파드를 다시 만들어야 함 (Deployment면 `kubectl rollout restart`) |
| `configMap` 볼륨 | 파일로 투영 | kubelet이 주기적으로 반영 (보통 1분 안팎). 단 `subPath` 로 마운트한 파일은 갱신되지 않음 |

키 전체를 환경 변수로 넣고 싶으면 `envFrom: [{configMapRef: {name: app-settings}}]` 를 씁니다. 이때
변수 이름은 키 이름(`MODE`, `COLOR`) 그대로이고 `prefix` 로 접두어만 붙일 수 있습니다. 이 문제처럼 키
하나만 `APP_MODE` 라는 다른 이름으로 받으려면 `configMapKeyRef` 입니다.

## 검증

```bash
kubectl -n cfg get pod settings-demo                          # Running
kubectl -n cfg exec settings-demo -- printenv APP_MODE        # prod
kubectl -n cfg exec settings-demo -- ls /etc/settings         # COLOR  MODE
kubectl -n cfg exec settings-demo -- cat /etc/settings/COLOR  # blue
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 키 하나를 다른 이름의 변수로 → `env[].valueFrom.configMapKeyRef`, ConfigMap 전체를 파일로 → `volumes[].configMap` + `volumeMounts`.
- **헷갈리는 지점**: 파드보다 ConfigMap이 먼저 있어야 합니다. 없는 ConfigMap을 env로 참조하면 `CreateContainerConfigError`, 볼륨으로 참조하면 `ContainerCreating` 에 멈춥니다(`kubectl describe pod` 이벤트에 이유가 나옴). 볼륨을 마운트한 디렉터리의 원래 내용은 가려집니다.

## 참고 문서

- 검색어: `configure a pod to use a configmap`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
- https://kubernetes.io/docs/concepts/configuration/configmap/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
