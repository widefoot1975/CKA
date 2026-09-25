# q16 — Read logs from an app and its sidecar · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`logs` 네임스페이스에 파드 `order-api` 가 있다. 앱 컨테이너 `api` 와 네이티브 사이드카 컨테이너
`log-agent`(`initContainers` 아래에 `restartPolicy: Always` 로 선언됨)를 갖고 있다.

1. `log-agent` 컨테이너 로그의 마지막 10줄을 `/opt/course/d16/agent.log` 에 쓴다.
2. 컨테이너 `api` 가 한 번 재시작했다. 그 **이전 인스턴스**의 로그를 `/opt/course/d16/api-previous.log` 에 쓴다.
3. 파드의 모든 컨테이너에서 최근 30분 동안 나온 로그 중 `ERROR` 가 들어 있는 줄을 모두
   `/opt/course/d16/errors.log` 에 쓴다. 각 줄 앞에는 그 줄이 나온 컨테이너 이름이 붙어 있어야 한다.

## 모범 풀이

```bash
kubectl -n logs get pod order-api -o jsonpath=\
'containers: {.spec.containers[*].name}{"\n"}initContainers: {.spec.initContainers[*].name}{"\n"}'
# containers: api
# initContainers: log-agent

mkdir -p /opt/course/d16
kubectl -n logs logs order-api -c log-agent --tail=10 > /opt/course/d16/agent.log
kubectl -n logs logs order-api -c api --previous > /opt/course/d16/api-previous.log
kubectl -n logs logs order-api --all-containers --prefix --since=30m \
  | grep ERROR > /opt/course/d16/errors.log
```

**컨테이너가 둘 이상이면 `-c` 로 고릅니다 — 이 문제의 핵심입니다.** `-c` 를 빼도 에러가 나지 않는다는 것이
함정입니다.

```bash
kubectl -n logs logs order-api --tail=3
# Defaulted container "api" out of: api, log-agent (init)      ← stderr 로 한 줄만
# ... 이후는 api 의 로그 ...
```

kubectl은 `kubectl.kubernetes.io/default-container` 어노테이션이 가리키는 컨테이너, 없으면
`spec.containers` 의 **첫 번째 컨테이너**를 조용히 골라 보여 줍니다. 출력을 파일로 돌리면 이 안내 문구는
화면에만 남고 파일에는 `api` 의 로그가 들어가, `log-agent` 를 읽었다고 착각하기 쉽습니다. 사이드카가
`initContainers` 에 선언되어 있어도 읽는 방법은 같습니다(`-c log-agent`).

| 옵션 | 뜻 |
|---|---|
| `--tail=10` | 마지막 10줄 |
| `--previous` (`-p`) | 직전에 종료된 인스턴스의 로그 (한 세대 전까지만 보관) |
| `--all-containers` | init 컨테이너(사이드카 포함)까지 모든 컨테이너 |
| `--prefix` | 줄마다 `[pod/<파드>/<컨테이너>]` 를 붙임 |
| `--since=30m` | 최근 30분 (절대 시각은 `--since-time=<RFC3339>`) |

## 검증

```bash
kubectl -n logs get pod order-api              # READY 2/2 — 네이티브 사이드카도 READY 에 포함, RESTARTS 1
wc -l < /opt/course/d16/agent.log              # 10
head -3 /opt/course/d16/api-previous.log
head -3 /opt/course/d16/errors.log
# [pod/order-api/api] 2026-09-26T10:12:03Z ERROR payment timeout ...
# [pod/order-api/log-agent] ... ERROR ...
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 멀티 컨테이너 파드는 항상 `-c <컨테이너>`. 재시작 전 로그는 `--previous`, 전체 컨테이너는 `--all-containers --prefix`.
- **헷갈리는 지점**: `-c` 와 `--all-containers` 를 함께 주면 에러입니다. 재시작한 적 없는 컨테이너에 `--previous` 를 주면 `previous terminated container ... not found` 가 납니다. 재시작 횟수는 앱 컨테이너는 `.status.containerStatuses`, 사이드카는 `.status.initContainerStatuses` 에 있습니다.

## 참고 문서

- 검색어: `logging architecture`, `sidecar containers`
- https://kubernetes.io/docs/concepts/cluster-administration/logging/
- https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
