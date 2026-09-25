# q17 — Find the heaviest Pod with kubectl top · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

클러스터에 metrics-server가 돌고 있다. `batch` 네임스페이스의 파드 몇 개가 바쁘게 일하고 있다.

1. `batch` 네임스페이스에서 지금 CPU를 가장 많이 쓰는 파드의 이름을 `/opt/course/d17/pod.txt` 에 적는다
   (파드 이름만).
2. 지금 메모리를 절대량 기준(퍼센트가 아니라 바이트)으로 가장 많이 쓰는 노드의 이름을
   `/opt/course/d17/node.txt` 에 적는다(노드 이름만).

## 모범 풀이

```bash
mkdir -p /opt/course/d17

kubectl top pod -n batch --sort-by=cpu
# NAME         CPU(cores)   MEMORY(bytes)
# cruncher-2   412m         18Mi
# cruncher-1   96m          12Mi
# idle-0       1m           3Mi
kubectl top pod -n batch --sort-by=cpu --no-headers | head -1 | awk '{print $1}' > /opt/course/d17/pod.txt

kubectl top node --sort-by=memory
# NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
# cp01       310m         15%      2210Mi          58%
# worker02   520m         26%      1840Mi          48%
# worker01   130m         6%       1320Mi          34%
kubectl top node --sort-by=memory --no-headers | head -1 | awk '{print $1}' > /opt/course/d17/node.txt
```

**`--sort-by` 는 큰 값부터 정렬합니다 — 이 문제의 핵심입니다.** `--no-headers` 로 머리글을 없애면 첫 줄이
곧 1등이라 `head -1` 과 `awk '{print $1}'` 로 이름만 뽑을 수 있습니다. 눈으로 읽고 옮겨 적으면
`cruncher-2` 와 `cruncher-1` 같은 비슷한 이름에서 실수하기 쉽습니다.

- `--sort-by=memory` 는 `MEMORY(bytes)` **절대량** 기준입니다. 노드마다 전체 메모리가 다르면
  `MEMORY(%)` 순서와 다를 수 있습니다.
- 값은 metrics-server가 최근 짧은 구간에서 모은 **실제 사용량**(request/limit이 아님)이라 조금씩 변합니다.
  명령을 두세 번 실행해 1등이 바뀌지 않는지 봅니다.
- 컨테이너별로 보려면 `--containers`, 모든 네임스페이스는 `-A` 입니다.

## 검증

```bash
cat /opt/course/d17/pod.txt           # cruncher-2   (이름 한 단어만, 머리글 없음)
cat /opt/course/d17/node.txt          # cp01
kubectl get pod -n batch "$(cat /opt/course/d17/pod.txt)"    # 실제로 존재하는 파드 이름인지
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubectl top pod|node --sort-by=cpu|memory --no-headers | head -1 | awk '{print $1}'`.
- **헷갈리는 지점**: `error: Metrics API not available` 이면 metrics-server가 동작하지 않는 것입니다(`kubectl get apiservice v1beta1.metrics.k8s.io` 로 확인). 파드를 막 만든 직후에는 첫 수집 전이라 `metrics not available yet` 이 잠시 나올 수 있습니다.

## 참고 문서

- 검색어: `resource metrics pipeline`, `kubectl top`
- https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/
- https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-usage-monitoring/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
