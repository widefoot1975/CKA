# q16 — Collect logs from every container of a Pod · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `obs` 의 Pod `pipeline` 에는 init 컨테이너 `migrate` 하나와 컨테이너 `ingest`, `transform`
두 개가 있다. 파드는 `Running` 이다.

1. Pod `pipeline` 의 모든 컨테이너 이름을 한 줄에 하나씩 `/opt/course/f16/containers.txt` 에 쓴다. init
   컨테이너를 먼저, 그다음 일반 컨테이너를, 각각 spec 에 적힌 순서대로 쓴다.
2. init 컨테이너를 포함한 `pipeline` 의 모든 컨테이너 로그를, 각 줄 앞에 그 줄이 나온 컨테이너를 붙여
   `/opt/course/f16/all.log` 에 쓴다.
3. 컨테이너 `transform` 이 최근 15분 동안 남긴 로그 중 `ERROR` 가 들어간 줄만 타임스탬프와 함께
   `/opt/course/f16/transform-errors.log` 에 쓴다.

## 모범 풀이

```bash
mkdir -p /opt/course/f16

# 1) init 컨테이너 → 일반 컨테이너 순서
kubectl -n obs get pod pipeline -o jsonpath=\
'{range .spec.initContainers[*]}{.name}{"\n"}{end}{range .spec.containers[*]}{.name}{"\n"}{end}' \
  > /opt/course/f16/containers.txt

# 2) 모든 컨테이너, 출처 접두어
kubectl -n obs logs pipeline --all-containers --prefix > /opt/course/f16/all.log

# 3) transform 만, 최근 15분, 타임스탬프, ERROR 줄만
kubectl -n obs logs pipeline -c transform --since=15m --timestamps | grep ERROR \
  > /opt/course/f16/transform-errors.log
```

**핵심 — 멀티 컨테이너 파드에서 `kubectl logs` 는 컨테이너 하나만 보여 줍니다.** `-c` 없이 실행하면 오류가
나지 않고 `kubectl.kubernetes.io/default-container` 어노테이션의 컨테이너, 없으면 첫 번째 컨테이너를
고릅니다. 이때 안내 문구는 stderr 로 나오므로 `> 파일` 에는 남지 않고, 다른 컨테이너의 로그가 빠진 것을
놓치기 쉽습니다.

```bash
kubectl -n obs logs pipeline
# Defaulted container "ingest" out of: ingest, transform, migrate (init)     ← stderr
```

| 옵션 | 뜻 |
|---|---|
| `-c <이름>` | 그 컨테이너 하나 (init 컨테이너도 이름으로 지정 가능) |
| `--all-containers` | init 컨테이너를 포함한 모든 컨테이너. 컨테이너별로 차례로 이어 붙음(시간순 병합 아님) |
| `--prefix` | 각 줄 앞에 `[pod/<파드>/<컨테이너>]` |
| `--since=15m` / `--timestamps` | 최근 15분만 / 각 줄 앞에 RFC3339 타임스탬프 |

## 검증

```bash
cat /opt/course/f16/containers.txt
# migrate
# ingest
# transform
cut -d' ' -f1 /opt/course/f16/all.log | sort | uniq -c
#   2 [pod/pipeline/ingest]
#   3 [pod/pipeline/migrate]
#   5 [pod/pipeline/transform]         (줄 수는 예시 — 세 컨테이너가 모두 보여야 한다)
head -2 /opt/course/f16/transform-errors.log
# 2026-09-26T10:41:07.123456789Z ERROR ...
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: 모든 컨테이너 = `--all-containers --prefix`, 하나 = `-c <이름>`. `--all-containers` 는 init 컨테이너도 포함한다.
- **헷갈리는 지점**: `--all-containers` 와 `-c` 를 함께 쓰면 오류입니다. 시간으로 자를 때는 `--since=15m`(상대 시간)이나 `--since-time=<RFC3339 시각>`(절대 시각)을 씁니다. `--tail` 은 줄 수로 자르는 옵션이라 "최근 15분"을 보장하지 못합니다.

## 참고 문서

- 검색어: `kubectl logs`
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/
- https://kubernetes.io/docs/concepts/cluster-administration/logging/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
