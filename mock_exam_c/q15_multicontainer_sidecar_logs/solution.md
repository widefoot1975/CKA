# q15 — Read output streams from a multi-container pod · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `obs` 에 컨테이너 `app`, `shipper` 와 init 컨테이너 `setup` 을 가진 파드 `tracker` 가
있다. 동료가 `kubectl logs tracker` 를 실행해 에러 없이 출력을 받았고, 그걸 보고 `shipper` 가 정상이라고
결론 내렸다.

1. 그냥 `kubectl logs tracker` 가 실제로 어느 컨테이너의 로그를 출력했는지와 그 이유를 보고하고,
   매니페스트 전체를 읽지 않고 파드의 컨테이너 목록(init 컨테이너 포함)을 나열한다. 그리고 파드를
   다시 만들지 않고, 그냥 `kubectl logs tracker` 가 `shipper` 를 보여 주도록 만든다.
2. `app` 컨테이너 로그의 마지막 20줄을 `/opt/course/q15/app.log` 에 쓴다.
3. `shipper` 컨테이너가 한 번 재시작했다. 그 **이전** 인스턴스의 로그를
   `/opt/course/q15/shipper-prev.log` 에 쓰고 재시작 이유를 적는다.
4. 최근 10분 동안 어떤 컨테이너든 출력한 줄 중 `ERROR` 를 포함하는 모든 줄을
   `/opt/course/q15/errors.log` 에 쓴다.
5. `obs` 에 새 파드 `tailer` 를 만든다. `nginx:1.27` 이 공유 `emptyDir` 의
   `/var/log/nginx/access.log` 에 액세스 로그를 쓰고, 네이티브 사이드카 `logship`
   (`busybox:1.36`)이 그 파일을 자기 stdout으로 tail한다. `kubectl logs tailer -c logship` 이
   nginx 요청을 보여 주는 것을 증명한다.

## 모범 풀이

**1) 에러가 안 난다는 것이 함정입니다**

```bash
kubectl -n obs logs tracker
# Defaulted container "app" out of: app, shipper, setup (init)     ← stderr 로 한 줄
# ... 이후는 app 의 로그 ...
```

예전 kubectl은 컨테이너가 여럿이면 `a container name must be specified` 로 거부했지만, 지금은
**에러를 내지 않습니다.** `kubectl.kubernetes.io/default-container` 어노테이션이 가리키는 컨테이너,
없으면 `spec.containers` 의 **첫 번째 컨테이너**(`app`)를 골라 로그를 보여 주고, 그 사실은 stderr에
`Defaulted container ...` 한 줄로만 남깁니다. 출력을 파일로 돌리거나 파이프로 넘기면 이 한 줄이
화면에서 쉽게 묻혀서, 동료처럼 `app` 의 로그를 보고 `shipper` 를 판단하는 사고가 납니다.

컨테이너 목록은 위 안내 문구에도 나오고, 명시적으로는:

```bash
kubectl -n obs get pod tracker -o jsonpath='{.spec.containers[*].name}{"\n"}{.spec.initContainers[*].name}{"\n"}'
```

기본 컨테이너를 바꾸는 것은 어노테이션 하나입니다. 어노테이션은 실행 중인 파드에도 바꿀 수 있어서
다시 만들 필요가 없습니다(Deployment라면 파드 템플릿에 넣습니다).

```bash
kubectl -n obs annotate pod tracker kubectl.kubernetes.io/default-container=shipper
kubectl -n obs logs tracker --tail=3        # 이제 안내 문구 없이 shipper 의 로그
```

**2~4) 로그 수집**

```bash
mkdir -p /opt/course/q15

kubectl -n obs logs tracker -c app --tail=20 > /opt/course/q15/app.log

kubectl -n obs logs tracker -c shipper --previous > /opt/course/q15/shipper-prev.log
kubectl -n obs describe pod tracker | grep -A8 'shipper'
# Last State: Terminated / Reason: ... / Exit Code: ...

kubectl -n obs logs tracker --all-containers --since=10m --prefix \
  | grep ERROR > /opt/course/q15/errors.log      # --prefix 로 어느 컨테이너의 줄인지 남긴다
```

`--previous` (`-p`)는 재시작 **한 세대 전**의 로그만 줍니다. 두 세대 전은 가져올 수 없습니다 —
kubelet이 이전 컨테이너 하나만 보관합니다. 그래서 재시작 원인 조사는 재시작이 더 쌓이기 전에
해야 합니다. `--all-containers` 는 init 컨테이너까지 포함하고, `--since=10m` 은 상대 시간,
`--since-time=2026-09-12T10:00:00Z` 는 절대 시간(RFC3339)입니다.

`describe` 가 아니라 정확한 필드로 재시작 이유를 뽑으려면:

```bash
kubectl -n obs get pod tracker -o jsonpath='{range .status.containerStatuses[?(@.name=="shipper")]}{.lastState.terminated.reason}{" exit="}{.lastState.terminated.exitCode}{"\n"}{end}'
```

**5) 네이티브 사이드카**

```yaml
# tailer.yaml
apiVersion: v1
kind: Pod
metadata:
  name: tailer
  namespace: obs
spec:
  volumes:
    - name: logs
      emptyDir: {}
  initContainers:
    - name: logship                    # initContainers 에 두고
      image: busybox:1.36
      restartPolicy: Always            # 이것이 네이티브 사이드카로 만든다
      command: ["sh", "-c", "tail -n+1 -F /var/log/nginx/access.log"]
      volumeMounts:
        - name: logs
          mountPath: /var/log/nginx
  containers:
    - name: nginx
      image: nginx:1.27
      volumeMounts:
        - name: logs
          mountPath: /var/log/nginx
```

```bash
kubectl apply -f tailer.yaml
kubectl -n obs wait --for=condition=Ready pod/tailer --timeout=60s
kubectl -n obs exec tailer -c nginx -- curl -s localhost > /dev/null
kubectl -n obs logs tailer -c logship
# 127.0.0.1 - - [...] "GET / HTTP/1.1" 200 ...
```

네이티브 사이드카는 **`initContainers` 배열에 있으면서 `restartPolicy: Always` 를 가진 컨테이너**
입니다 (1.29부터 기본 활성, **1.33 GA**). 일반 init 컨테이너와 달리 종료를 기다리지 않고, 다음 컨테이너 시작 전에
Started 상태가 되면 진행하며, 메인 컨테이너보다 먼저 시작하고 나중에 종료합니다. 그래서
`tail -F` 처럼 끝나지 않는 프로세스를 여기에 둘 수 있습니다 — 일반 init 컨테이너에 넣으면
파드가 `Init:0/1` 에서 영원히 멈춥니다. `containers` 에 나란히 두는 구식 사이드카도 동작하지만,
그 경우 Job에서 메인이 끝나도 사이드카가 살아 있어 Job이 완료되지 않는 문제가 있습니다.

`tail -F` (대문자)를 쓰는 이유는 파일이 아직 없을 때도 기다렸다가 생기면 읽기 때문입니다.
`tail -f` 는 파일이 없으면 즉시 실패하고, nginx가 로그 파일을 만들기 전에 사이드카가 먼저 뜨므로
경쟁 조건에 걸립니다.

참고로 공식 nginx 이미지는 `/var/log/nginx/access.log` 를 `/dev/stdout` 으로 가는 심볼릭 링크로
만들어 둡니다. 여기에 emptyDir을 마운트하면 그 링크가 가려지고, nginx가 빈 디렉터리에 **진짜 파일**을
새로 만들어 쓰기 때문에 사이드카가 tail할 수 있습니다. 그 대신 nginx 컨테이너 자신의
`kubectl logs` 에는 액세스 로그가 더 이상 나오지 않습니다.

## 검증

```bash
wc -l /opt/course/q15/app.log            # 20
head -2 /opt/course/q15/shipper-prev.log
cat /opt/course/q15/errors.log | grep -c ERROR

kubectl -n obs get pod tailer
# READY 2/2   STATUS Running     ← 네이티브 사이드카는 READY 분모에 포함된다

kubectl -n obs get pod tailer -o jsonpath='{.spec.initContainers[0].restartPolicy}{"\n"}'   # Always
kubectl -n obs exec tailer -c nginx -- curl -s localhost -o /dev/null
kubectl -n obs logs tailer -c logship --tail=5   # GET / HTTP/1.1" 200
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 멀티 컨테이너 파드는 `-c <이름>`. `-c` 를 빼면 에러 없이 기본 컨테이너(어노테이션 또는 첫 번째)의 로그가 나오고 stderr에 `Defaulted container` 한 줄만 남는다. 재시작 원인은 `--previous`, 전체 훑기는 `--all-containers --since= --prefix`.
- **헷갈리는 지점**: `kubectl logs -c x` 와 `kubectl exec -c x` 의 `-c` 는 같은 의미지만,
  `kubectl logs deploy/foo` 는 파드 하나만 골라 보여 주고 `kubectl logs -l app=foo` 는 셀렉터에
  맞는 모든 파드를 보여 줍니다. 그리고 `--tail` 의 기본값은 셀렉터(`-l`)를 쓸 때만 10이고,
  파드를 이름으로 지정하면 전체 로그입니다 — 셀렉터로 조회했다가 10줄만 보고 "로그가 없다"고
  오판하는 경우가 있습니다.

## 참고 문서

- 검색어: `logging architecture sidecar`
- https://kubernetes.io/docs/concepts/cluster-administration/logging/
- https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
