# q04 — 노드 유지보수 (drain / uncordon)

| 항목 | 내용 |
|---|---|
| 회차 | mock_exam_a |
| 도메인 | Cluster Architecture, Installation & Configuration (25%) |
| 배점 | 5 |
| 컨텍스트 | `kubectl config use-context k8s-c1` |
| 목표 시간 | 5분 |
| 결과 | ☐ 정답 ☐ 부분 ☐ 오답 |

## 문제

노드 `worker02` 를 점검하기 위해 워크로드를 비운다.

1. `worker02` 에서 실행 중인 파드를 다른 노드로 옮기고, 새 파드가 이 노드에 스케줄되지 않게 한다.
2. DaemonSet 파드 때문에 명령이 멈추지 않게 처리한다.
3. `emptyDir` 을 쓰는 파드가 있어 거부되면 그것도 통과시킨다.
4. 점검이 끝났다고 가정하고 노드를 원래 상태로 되돌린다.
5. 추가로, `worker02` 에 `maintenance=true:NoSchedule` taint를 걸었다가 다시 제거한다.

## 내 풀이

```bash

```

<details>
<summary><b>모범 풀이</b> — 직접 풀고 나서 펼치세요</summary>

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

</details>

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
