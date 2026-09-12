# q04 — Node maintenance with drain and uncordon · 풀이

← 문제: **[question.md](question.md)**

## 모범 풀이

```bash
# 1~3) 비우기
kubectl drain worker02 --ignore-daemonsets --delete-emptydir-data

# 상태 확인 — SchedulingDisabled 로 표시됨
kubectl get nodes

# 4) 복귀
kubectl uncordon worker02

# 5) taint 추가 / 제거 (제거는 key 뒤에 하이픈)
kubectl taint node worker02 maintenance=true:NoSchedule
kubectl taint node worker02 maintenance=true:NoSchedule-
```

`drain` 은 내부적으로 `cordon`(스케줄 차단) + 기존 파드 eviction 입니다. 스케줄만 막고 기존 파드는 그대로 두려면 `kubectl cordon worker02` 만 씁니다.

## 검증

```bash
kubectl get nodes                                   # STATUS 에 SchedulingDisabled 없음
kubectl get pods -A -o wide | grep worker02          # drain 직후에는 DaemonSet 파드만 남음
kubectl describe node worker02 | grep -A3 Taints     # taint 없음
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: `--ignore-daemonsets` 와 `--delete-emptydir-data` 는 거의 항상 같이 씁니다.
- **헷갈리는 지점**: taint 제거는 `kubectl taint node <node> <key>-` — 뒤에 하이픈. `kubectl untaint` 라는 명령은 없습니다.

## 참고 문서

- 검색어: `safely drain node`
- https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
