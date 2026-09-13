# q15 — Read output streams from a multi-container pod · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `obs` 에 컨테이너 `app`, `shipper` 와 init 컨테이너 `setup` 을 가진 파드 `tracker` 가
있다. `kubectl logs tracker` 는 오류를 반환한다.

1. 그냥 `kubectl logs tracker` 가 실패하는 이유를 설명하고, 매니페스트 전체를 읽지 않고 파드의
   컨테이너 목록을 나열한다.
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

**1) 왜 실패하고, 컨테이너 목록 보기**

```bash
kubectl -n obs logs tracker
# error: a container name must be specified for pod tracker, choose one of:
#   [app shipper] and one of the init containers: [setup]
```

컨테이너가 둘 이상이면 `kubectl logs` 는 어느 스트림을 줄지 결정할 수 없어 거부합니다.
오류 메시지 자체가 컨테이너 목록이므로 이것만으로도 답이 됩니다. 명시적으로는:

```bash
kubectl -n obs get pod tracker -o jsonpath='{.spec.containers[*].name}{"\n"}{.spec.initContainers[*].name}{"\n"}'
```

**2~4) 로그 수집**

```bash
mkdir -p /opt/course/q15

kubectl -n obs logs tracker -c app --tail=20 > /opt/course/q15/app.log

kubectl -n obs logs tracker -c shipper --previous > /opt/course/q15/shipper-prev.log
kubectl -n obs describe pod tracker | grep -A8 'shipper'
# Last State: Terminated / Reason: ... / Exit Code: ...

kubectl -n obs logs tracker --all-containers --since=10m \
  | grep ERROR > /opt/course/q15/errors.log
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
입니다 (v1.29 GA). 일반 init 컨테이너와 달리 종료를 기다리지 않고, 다음 컨테이너 시작 전에
Started 상태가 되면 진행하며, 메인 컨테이너보다 먼저 시작하고 나중에 종료합니다. 그래서
`tail -F` 처럼 끝나지 않는 프로세스를 여기에 둘 수 있습니다 — 일반 init 컨테이너에 넣으면
파드가 `Init:0/1` 에서 영원히 멈춥니다. `containers` 에 나란히 두는 구식 사이드카도 동작하지만,
그 경우 Job에서 메인이 끝나도 사이드카가 살아 있어 Job이 완료되지 않는 문제가 있습니다.

`tail -F` (대문자)를 쓰는 이유는 파일이 아직 없을 때도 기다렸다가 생기면 읽기 때문입니다.
`tail -f` 는 파일이 없으면 즉시 실패하고, nginx가 로그 파일을 만들기 전에 사이드카가 먼저 뜨므로
경쟁 조건에 걸립니다.

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
- **기억할 것**: 멀티 컨테이너 파드는 `-c <이름>`. 재시작 원인은 `--previous`, 전체 훑기는 `--all-containers --since=`.
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
