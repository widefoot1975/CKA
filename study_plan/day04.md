# 4일차 (D-7) — 워크로드와 스케줄링

[← 3일차](day03.md) · [계획 전체](README.md) · [5일차 →](day05.md)

## 오늘의 목표

Workloads & Scheduling(15%)을 하루에 끝냅니다. 문제 하나하나는 짧지만 개수가 많은 날이라, **문제마다 5분**을 지키는 연습을 합니다.

## 시간표

| 시간 | 할 일 |
|---|---|
| 0:00 – 0:12 | [exam_guide.md](../exam_guide.md) §5 Workloads & Scheduling (§5.3 오토스케일링, §5.5 스케줄링 위주) |
| 0:12 – 0:42 | 아래 문제 6개 풀기 (문제당 5분) |
| 0:42 – 0:57 | `solution.md` 와 대조, 오답 원인 기록 |
| 0:57 – 1:00 | 회차 README의 `실제`·`결과` 칸 채우기 |

## 풀 문제

| 문제 | 주제 | 배점 | 목표 | 결과 |
|---|---|---|---|---|
| D07 | taint와 toleration으로 노드 전용화 | 5 | 5분 | [Q](../mock_exam_d/q07_taint_toleration_dedicated_node/question.md) · [S](../mock_exam_d/q07_taint_toleration_dedicated_node/solution.md) ☐ |
| E05 | HPA로 Deployment 오토스케일 | 5 | 5분 | [Q](../mock_exam_e/q05_hpa_behavior/question.md) · [S](../mock_exam_e/q05_hpa_behavior/solution.md) ☐ |
| E06 | init 컨테이너까지 모든 컨테이너에 리소스 설정 | 5 | 5분 | [Q](../mock_exam_e/q06_resource_requests_all_containers/question.md) · [S](../mock_exam_e/q06_resource_requests_all_containers/solution.md) ☐ |
| E07 | 기존 Deployment에 네이티브 사이드카 추가 | 5 | 5분 | [Q](../mock_exam_e/q07_native_sidecar_log_shipper/question.md) · [S](../mock_exam_e/q07_native_sidecar_log_shipper/solution.md) ☐ |
| F05 | 기존 값을 기준으로 PriorityClass 생성 | 5 | 5분 | [Q](../mock_exam_f/q05_priorityclass_derived_value/question.md) · [S](../mock_exam_f/q05_priorityclass_derived_value/solution.md) ☐ |
| F07 | CronJob 생성과 수동 실행 | 5 | 5분 | [Q](../mock_exam_f/q07_cronjob_manual_trigger/question.md) · [S](../mock_exam_f/q07_cronjob_manual_trigger/solution.md) ☐ |

합계 30점, 목표 30분.

## 꼭 잡을 것

```bash
kubectl taint nodes <node> dedicated=gpu:NoSchedule
kubectl autoscale deploy web --cpu=50% --min=2 --max=5
kubectl set resources deploy web -c app --requests=cpu=100m,memory=128Mi --limits=memory=256Mi
kubectl get priorityclass --sort-by=.value
kubectl create cronjob backup --image=busybox --schedule="*/5 * * * *" -- /bin/sh -c 'date'
kubectl create job backup-manual --from=cronjob/backup
```

- toleration만 주면 특정 노드로 **가지 않습니다**. nodeSelector나 affinity가 함께 있어야 합니다 (함정 23).
- HPA가 `<unknown>` 이면 requests가 없거나 metrics-server가 없는 것입니다. `behavior` 는 명령형 플래그가 없어 yaml로 넣습니다 (함정 18, 19).
- 네이티브 사이드카는 `initContainers` 에 `restartPolicy: Always` 를 붙입니다 (함정 20).
- PriorityClass의 "기존 최댓값 - 1" 은 `system-*` 를 빼고, 새 클래스를 만들기 **전에** 계산합니다 (함정 26).
- Job에 `restartPolicy: Always` 는 거부됩니다 (함정 27).

## 여유가 있으면

- 기본 [F06 ConfigMap 갱신 후 immutable로 잠그기](../mock_exam_f/q06_configmap_update_immutable/question.md)
- 심화 [B05 HPA 워크로드 오토스케일링](../mock_exam_b/q05_hpa_workload_autoscaling/question.md)
- 심화 [B06 ResourceQuota와 LimitRange](../mock_exam_b/q06_resourcequota_limitrange/question.md)
