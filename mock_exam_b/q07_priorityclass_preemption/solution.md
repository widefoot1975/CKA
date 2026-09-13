# q07 — Pod priority and preemption · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

`sched` 네임스페이스에서 배치 채우기 작업이 결제 처리에 자리를 양보해야 한다.

1. PriorityClass 세 개를 만든다. 어느 것도 `globalDefault` 가 아니다.
   - `low-priority`, value `1000`
   - `critical-priority`, value `100000`, description `payment path`
   - `queue-jumper`, value `50000`, 다른 파드를 **절대** evict하지 않아야 한다
2. `sched` 에 deployment `filler` 를 만든다. image `nginx:1.27`, replica 6,
   priority class `low-priority`, 각 컨테이너가 `cpu: 400m` 을 요청해 클러스터 allocatable CPU가
   고갈되고 최소 한 replica가 `Pending` 으로 남게 한다.
3. `sched` 에 파드 `payment` 를 만든다. image `nginx:1.27`, priority class
   `critical-priority`, `cpu: 500m` 요청.
4. `payment` 가 스케줄되고 `filler` 파드 하나가 preempt되었음을 보인다. preemptor를 지목하는
   이벤트 메시지를 `/opt/q07/preempt.txt` 에 적는다.
5. `queue-jumper` 가 preempt를 못 하는데도 높은 value로부터 얻는 것이 무엇인지
   `/opt/q07/never.txt` 에 적는다.

## 모범 풀이

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 1000
globalDefault: false
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-priority
value: 100000
globalDefault: false
description: "payment path"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: queue-jumper
value: 50000
globalDefault: false
preemptionPolicy: Never
```

PriorityClass는 네임스페이스가 없는 클러스터 범위 오브젝트입니다. `-n` 을 붙여도 무시됩니다.

```bash
kubectl apply -f pc.yaml
kubectl create namespace sched
kubectl -n sched create deploy filler --image=nginx:1.27 --replicas=6
kubectl -n sched set resources deploy filler --requests=cpu=400m
kubectl -n sched patch deploy filler \
  -p '{"spec":{"template":{"spec":{"priorityClassName":"low-priority"}}}}'
```

`kubectl run` / `create deploy` 에는 `--priority-class-name` 플래그가 없습니다. patch나
`kubectl -n sched edit deploy filler` 로 `spec.template.spec.priorityClassName` 을 넣습니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: payment
  namespace: sched
spec:
  priorityClassName: critical-priority
  containers:
  - name: web
    image: nginx:1.27
    resources:
      requests:
        cpu: 500m
```

**preempt는 `Pending` 인 파드가 있을 때만 일어납니다.** 스케줄러가 `payment` 를 놓을 노드를
찾지 못하면, 그 노드에서 자신보다 우선순위가 낮은 파드를 골라 삭제하고 자리를 만듭니다. 그래서
2번에서 실제로 CPU를 고갈시켜 `Pending` 상태를 만들어야 하며, 여유가 남아 있으면 아무 일도
일어나지 않아 4번을 증명할 수 없습니다. 피해자 파드에는 종료 전에 이벤트가 남습니다.

```bash
kubectl -n sched get events --sort-by=.lastTimestamp | grep -i preempt
# Preempted by pod <uid> on node worker01
# 또는 payment 쪽:  Successfully assigned ... / preemption victim(s) found
```

`preemptionPolicy: Never` 는 우선순위를 없애는 것이 아닙니다. 그 파드는 **스케줄링 큐에서는
여전히 앞자리**를 차지해 낮은 우선순위 파드보다 먼저 심사받습니다. 다만 자리가 없으면 남을
쫓아내지 않고 `Pending` 으로 기다립니다. 즉 "새치기는 하지만 쫓아내지는 않는다"가 답입니다.

## 검증

```bash
kubectl get priorityclass
# NAME                VALUE    GLOBAL-DEFAULT  AGE
# critical-priority   100000   false
# low-priority        1000     false
# queue-jumper        50000    false

kubectl -n sched get pod payment -o wide          # Running, 노드 배정됨
kubectl -n sched get pods -l app=filler           # 하나 이상이 Pending 으로 밀려난다
kubectl -n sched get pod payment \
  -o jsonpath='{.spec.priority}{"\n"}'            # 100000 (admission 이 채워 넣는다)
kubectl -n sched describe pod payment | grep -iA2 -e priority -e preempt
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: preempt는 고우선순위 파드가 `Pending` 으로 막혔을 때만 발동한다. 클러스터에 여유가 있으면 우선순위는 아무것도 하지 않는다.
- **헷갈리는 지점**: `preemptionPolicy: Never` 와 낮은 value는 다릅니다 — 전자는 큐 우선권은 유지하고 축출만 포기합니다. 그리고 `globalDefault: true` 는 클러스터 전체에서 단 하나만 허용되고, `priorityClassName` 을 안 쓴 파드에만 적용되며, 이미 존재하는 파드의 priority는 바뀌지 않습니다. `spec.priority` 는 직접 쓰지 않습니다 — admission이 클래스에서 복사합니다.

## 참고 문서

- 검색어: `pod priority and preemption`
- https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
