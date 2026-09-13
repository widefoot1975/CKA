# q07 — Pod priority and preemption

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Context | `kubectl config use-context k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Task

Namespace `sched` runs batch filler work that must yield to payment processing.

1. Create three PriorityClasses, none of them `globalDefault`:
   - `low-priority`, value `1000`
   - `critical-priority`, value `100000`, description `payment path`
   - `queue-jumper`, value `50000`, which must **never** evict another pod
2. In `sched`, create deployment `filler` with image `nginx:1.27`, 6 replicas, priority
   class `low-priority`, each container requesting `cpu: 400m`, so that the cluster's
   allocatable CPU is exhausted and at least one replica stays `Pending`.
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
