# q17 — Analyse resource usage per node and container · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`k8s-c1` 클러스터에는 metrics-server가 설치되어 정상 동작 중이다.

1. 현재 CPU를 가장 많이 쓰는 노드의 이름을 `/opt/course/e17/node.txt` 에 쓴다.
2. `monitoring` 네임스페이스의 Pod `analytics` 에는 컨테이너 `collector` 와 `exporter` 가 있다. 현재
   메모리를 더 많이 쓰는 컨테이너의 이름을 `/opt/course/e17/container.txt` 에 쓴다.
3. `monitoring` 네임스페이스에서 현재 메모리를 가장 많이 쓰는 파드의 이름을 `/opt/course/e17/pod.txt`
   에 쓴다.

## 모범 풀이

`kubectl top` 은 metrics-server가 모은 **실제 사용량**을 보여 줍니다. `--sort-by=cpu|memory` 로
정렬하면 첫 줄이 답입니다.

```bash
mkdir -p /opt/course/e17
```

**1) 노드**

```bash
kubectl top node --sort-by=cpu
# NAME       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
# worker01   612m         30%    1650Mi          43%
# cp01       245m         12%    1480Mi          38%
# worker02   98m          4%     990Mi           26%
kubectl top node --sort-by=cpu --no-headers | head -1 | awk '{print $1}' > /opt/course/e17/node.txt
```

**2) 컨테이너별** — `kubectl top pod` 은 기본으로 파드 합계만 보여 주므로 `--containers` 가 필요합니다.

```bash
kubectl -n monitoring top pod analytics --containers
# POD         NAME        CPU(cores)   MEMORY(bytes)
# analytics   collector   3m           21Mi
# analytics   exporter    1m           74Mi
echo exporter > /opt/course/e17/container.txt      # 예시 — 실제 출력에서 MEMORY 가 큰 쪽
```

**3) 네임스페이스에서 메모리 1위 파드**

```bash
kubectl -n monitoring top pod --sort-by=memory
# NAME            CPU(cores)   MEMORY(bytes)
# analytics       4m           95Mi
# log-agent-x7k   2m           40Mi
kubectl -n monitoring top pod --sort-by=memory --no-headers | head -1 | awk '{print $1}' > /opt/course/e17/pod.txt
```

**`top` 은 사용량, `describe node` 는 예약량입니다.** `kubectl describe node` 의 `Allocated resources`
는 파드들의 **requests 합계**라서 "가장 많이 쓰는" 노드를 묻는 질문의 답이 아닙니다. metrics-server는
기본 15초 간격으로 수집하므로 값이 계속 조금씩 변합니다. 파일에는 조회한 시점의 결과를 적습니다.

## 검증

```bash
cat /opt/course/e17/node.txt /opt/course/e17/container.txt /opt/course/e17/pod.txt
kubectl top node --sort-by=cpu | sed -n 2p                   # node.txt 와 같은 이름
kubectl -n monitoring top pod analytics --containers         # container.txt 쪽 MEMORY 가 더 크다
kubectl -n monitoring top pod --sort-by=memory | sed -n 2p   # pod.txt 와 같은 이름
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `kubectl top node|pod --sort-by=cpu|memory`, 컨테이너별은 `--containers`, 첫 줄만 뽑을 때는 `--no-headers | head -1`.
- **헷갈리는 지점**: 파드 합계에는 사이드카 같은 다른 컨테이너의 사용량도 더해져 있으니, 컨테이너를 묻는 문항은 반드시 `--containers` 로 봅니다. `kubectl top` 이 `Metrics API not available` 을 내면 metrics-server 자체의 문제(B-q13)이고, 이 문제의 상황은 아닙니다.

## 참고 문서

- 검색어: `resource metrics pipeline`, `kubectl top`
- https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
