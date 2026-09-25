# q12 — Combine a Secret, a ConfigMap and pod labels in one volume · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `proj` 에 키 `password` 를 가진 Secret `db-cred` 와 키 `app.conf` 를 가진 ConfigMap `app-cfg`
가 있다.

1. 네임스페이스 `proj` 에 라벨 `app=demo`, image `busybox:1.36`, 명령 `sleep 3600` 인 Pod `projected-demo`
   를 만든다.
2. 그 파드의 `/etc/app` 에 `projected` 볼륨 **하나**를 읽기 전용으로 마운트한다. 이 볼륨은 다음을 제공해야 한다.
   - Secret `db-cred` 의 키 `password` → `/etc/app/password`
   - ConfigMap `app-cfg` 의 키 `app.conf` → `/etc/app/app.conf`
   - 파드의 라벨(Downward API 필드 `metadata.labels`) → `/etc/app/labels`
3. 파드 안에서 `ls` 와 `cat` 으로 세 파일이 모두 있고 기대한 내용인지 확인한다.

## 모범 풀이

뼈대를 만들고 볼륨 부분을 추가합니다.

```bash
kubectl -n proj run projected-demo --image=busybox:1.36 --labels=app=demo \
  --dry-run=client -o yaml --command -- sleep 3600 > pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: projected-demo
  namespace: proj
  labels: {app: demo}
spec:
  containers:
  - name: projected-demo
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - {name: app-files, mountPath: /etc/app, readOnly: true}
  volumes:
  - name: app-files
    projected:                        # 볼륨 하나에 소스 셋
      sources:
      - secret:
          name: db-cred
          items: [{key: password, path: password}]
      - configMap:
          name: app-cfg
          items: [{key: app.conf, path: app.conf}]
      - downwardAPI:
          items:
          - path: labels
            fieldRef: {fieldPath: metadata.labels}
```

`kubectl apply -f pod.yaml` 로 만듭니다.

**핵심 — 한 디렉터리에는 볼륨 하나만 마운트할 수 있습니다.** Secret 볼륨과 ConfigMap 볼륨을 따로 만들어
둘 다 `/etc/app` 에 마운트할 수는 없습니다. `projected` 는 여러 소스(`secret`, `configMap`, `downwardAPI`,
`serviceAccountToken` 등)를 **하나의 볼륨**으로 합쳐 한 디렉터리에 보여 줍니다. `items[].path` 는 마운트
경로 기준의 파일 이름입니다. 소스가 바뀌면 kubelet 이 파일을 잠시 뒤 갱신합니다(`subPath` 로 마운트한
경우는 갱신되지 않습니다).

## 검증

```bash
kubectl -n proj get pod projected-demo                         # Running
kubectl -n proj exec projected-demo -- ls /etc/app
# app.conf
# labels
# password
kubectl -n proj exec projected-demo -- cat /etc/app/labels     # app="demo"
kubectl -n proj exec projected-demo -- cat /etc/app/password   # Secret 값 (base64 가 풀린 평문)
kubectl -n proj exec projected-demo -- cat /etc/app/app.conf   # ConfigMap 내용
kubectl -n proj exec projected-demo -- touch /etc/app/x
# touch: /etc/app/x: Read-only file system
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 여러 소스를 한 디렉터리에 = `volumes[].projected.sources[]` 에 `secret` / `configMap` / `downwardAPI` 를 나열한다.
- **헷갈리는 지점**: downwardAPI 의 라벨 파일은 `key="value"` 형식으로 한 줄에 하나씩 쓰입니다. 그리고 `items` 를 지정하면 **나열한 키만** 파일이 되고, `items` 를 생략하면 소스의 모든 키가 키 이름 그대로 파일이 됩니다.

## 참고 문서

- 검색어: `projected volumes`
- https://kubernetes.io/docs/concepts/storage/projected-volumes/
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-projected-volume-storage/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
