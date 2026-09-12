# q07 — ConfigMap·Secret을 env와 volume으로 주입

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Workloads & Scheduling (15%) |
| 배점 | 5 |
| 컨텍스트 | `kubectl config use-context k8s-c1` |
| 목표 시간 | 7분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

`app` 네임스페이스에서 다음을 만든다.

1. ConfigMap `app-config`: `APP_MODE=production`, `LOG_LEVEL=warn`
2. Secret `db-credentials`: `DB_USER=admin`, `DB_PASSWORD=s3cr3t`
3. 파드 `configured-app` (이미지 `nginx`):
   - ConfigMap의 **모든 키를 환경 변수로** 주입
   - Secret의 `DB_PASSWORD` 만 환경 변수 `DATABASE_PASSWORD` 로 주입
   - Secret 전체를 `/etc/db` 경로에 **볼륨으로 마운트** (읽기 전용)
4. 파드 안에서 환경 변수와 마운트된 파일을 확인한다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 직접 풀고 나서 펼치세요</summary>

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

</details>

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
