# q07 — Inject a ConfigMap and Secret as env vars and a volume · 풀이

← 문제: **[question.md](question.md)**

## 모범 풀이

```bash
kubectl create namespace app

kubectl -n app create configmap app-config \
  --from-literal=APP_MODE=production \
  --from-literal=LOG_LEVEL=warn

kubectl -n app create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=s3cr3t
```

`configured-app.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configured-app
  namespace: app
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:                      # ConfigMap 전체를 env 로
    - configMapRef:
        name: app-config
    env:                          # Secret 의 특정 키만, 이름 바꿔서
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_PASSWORD
    volumeMounts:
    - name: db-secret
      mountPath: /etc/db
      readOnly: true
  volumes:
  - name: db-secret
    secret:
      secretName: db-credentials
```

```bash
kubectl apply -f configured-app.yaml
```

`envFrom` 은 전체 주입, `env[].valueFrom` 은 키 하나를 골라 이름까지 바꿀 때 씁니다. 문제가 "모든 키" 라고 하면 `envFrom`, "이 키를 이 이름으로" 라고 하면 `valueFrom`.

## 검증

```bash
kubectl -n app exec configured-app -- env | grep -E 'APP_MODE|LOG_LEVEL|DATABASE_PASSWORD'
kubectl -n app exec configured-app -- ls /etc/db          # DB_USER  DB_PASSWORD
kubectl -n app exec configured-app -- cat /etc/db/DB_USER # admin
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: Secret을 볼륨으로 마운트하면 **키 이름이 파일 이름**이 됩니다.
- **헷갈리는 지점**: `envFrom` 은 리스트이고 항목이 `configMapRef`/`secretRef`. `env` 는 항목이 `name`+`valueFrom`. 구조가 달라 자주 섞습니다 — `kubectl explain pod.spec.containers.envFrom` 으로 확인.

## 참고 문서

- 검색어: `configmap pod` / `distribute credentials secure`
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
- https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
