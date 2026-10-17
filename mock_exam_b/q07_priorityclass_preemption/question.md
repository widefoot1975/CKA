# q07 — Pod priority and preemption

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns sched --ignore-not-found --wait=true
kubectl delete priorityclass critical-priority low-priority queue-jumper --ignore-not-found
rm -rf /opt/q07

# 1) 다른 팀이 만들어 둔 사용자 정의 PriorityClass (모두 10000 초과, globalDefault 없음)
cat <<'YAML' | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: team-batch
value: 20000
globalDefault: false
description: "Team batch jobs"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: ml-training
value: 300000
globalDefault: false
description: "ML training workloads"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: ops-urgent
value: 750000
globalDefault: false
description: "Ops on-call tooling"
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: zz-observer
value: 600000
preemptionPolicy: Never
globalDefault: false
description: "Monitoring, never preempts"
YAML

# 2) 문제용 namespace (비어 있음)
kubectl create ns sched

# 3) 답안 파일 디렉터리
mkdir -p /opt/q07

# 4) 설정 확인
kubectl get pc --sort-by=.value
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu,TAINTS:.spec.taints[*].effect
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `sched` 는 비어 있고, `system-*` 를 뺀 사용자 정의 PriorityClass 는 `team-batch` · `ml-training` · `zz-observer` · `ops-urgent` 네 개다.
PriorityClass 는 클러스터 범위라 다른 문제(`mock_exam_f/q05` 등)의 클래스가 함께 있으면 기준 최댓값이 달라진다. 이 문제만 펼쳐 두고 푼다.
`filler` 가 워커 CPU 를 꽉 채우므로, 실습이 끝나면 꼭 정리한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns sched --ignore-not-found --wait=true
kubectl delete priorityclass critical-priority low-priority queue-jumper \
  team-batch ml-training ops-urgent zz-observer --ignore-not-found
rm -rf /opt/q07
```

</details>

## Task

Namespace `sched` runs batch filler work that must yield to payment processing. Other
teams have already created user-defined PriorityClasses in this cluster, all with values
above `10000`.

1. Create three PriorityClasses, none of them `globalDefault`:
   - `critical-priority`, description `payment path`, whose value is **one less than the
     highest user-defined PriorityClass that already exists** (ignore the built-in
     `system-*` classes)
   - `low-priority`, value `1000`
   - `queue-jumper`, value `50000`, which must **never** evict another pod
2. In `sched`, create deployment `filler` with image `nginx:1.27`, priority class
   `low-priority` and each container requesting `cpu: 400m`, with enough replicas that the
   cluster's allocatable CPU is exhausted and at least one replica stays `Pending`.
3. Create pod `payment` in `sched` with image `nginx:1.27`, priority class
   `critical-priority`, requesting `cpu: 500m`.
4. Show that `payment` becomes scheduled and that a `filler` pod was preempted. Write the
   event message naming the preemptor to `/opt/q07/preempt.txt`.
5. Write to `/opt/q07/never.txt` what `queue-jumper` still gains from its high value,
   given that it cannot preempt.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
