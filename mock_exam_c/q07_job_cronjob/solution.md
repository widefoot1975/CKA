# q07 — Run work with a Job and a CronJob · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

모든 작업은 네임스페이스 `batch` 에서 한다.

1. `busybox:1.36` 으로 `sh -c 'echo migrating; sleep 5; echo done'` 을 실행하는 Job `migrate` 를
   만든다. 4번 완료해야 하고, 동시에 최대 2개 파드만 실행되며, 3번 실패하면 포기하고,
   전체 Job이 120초를 넘으면 종료된다.
2. `backoffLimit: 2` 로 `sh -c 'exit 1'` 을 실행하는 Job `broken` 을 만든다. 최종 상태와
   파드를 몇 개 만들었는지 보인다.
3. `busybox:1.36` 으로 `sh -c 'date; echo report'` 를 5분마다 실행하는 CronJob `report` 를
   만든다. 히스토리에 성공 3개, 실패 1개를 남기고, 동시 실행을 금지하며, 스케줄 시각으로부터
   30초 안에 시작하지 못하면 실패로 표시한다.
4. 스케줄을 기다리지 않고 `report` 를 즉시 실행시키고 그 실행의 출력을 보인다.
5. 그 후 CronJob을 suspend한다.

## 모범 풀이

```yaml
# q07.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: migrate
  namespace: batch
spec:
  completions: 4
  parallelism: 2
  backoffLimit: 3
  activeDeadlineSeconds: 120
  template:
    spec:
      restartPolicy: Never            # Job에서는 Never 또는 OnFailure만 허용
      containers:
        - name: m
          image: busybox:1.36
          command: ["sh", "-c", "echo migrating; sleep 5; echo done"]
---
apiVersion: batch/v1
kind: Job
metadata:
  name: broken
  namespace: batch
spec:
  backoffLimit: 2
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: b
          image: busybox:1.36
          command: ["sh", "-c", "exit 1"]
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: report
  namespace: batch
spec:
  schedule: "*/5 * * * *"
  concurrencyPolicy: Forbid
  startingDeadlineSeconds: 30
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: r
              image: busybox:1.36
              command: ["sh", "-c", "date; echo report"]
```

```bash
kubectl apply -f q07.yaml
```

**4) 즉시 실행**

```bash
kubectl -n batch create job report-manual --from=cronjob/report
kubectl -n batch logs job/report-manual
```

`--from=cronjob/<name>` 은 CronJob의 `jobTemplate` 을 그대로 복사해 Job을 즉시 만듭니다.
스케줄을 임시로 `* * * * *` 로 바꿔 기다리는 것보다 빠르고, `concurrencyPolicy` 나
히스토리 한도에 영향을 주지 않습니다. 이것을 모르면 시간을 많이 낭비합니다.

**5) 중단**

```bash
kubectl -n batch patch cronjob report -p '{"spec":{"suspend":true}}'
```

**2) `broken` 이 만드는 파드 수**: `backoffLimit: 2` 는 **재시도 횟수**이므로 총 파드는 3개
(최초 1 + 재시도 2)입니다. 마지막 실패 후 Job에 `type: Failed`, `reason: BackoffLimitExceeded`
컨디션이 붙고 더 만들지 않습니다. 재시도 간격은 10초, 20초, 40초… 지수 백오프라 즉시 끝나지
않습니다.

`activeDeadlineSeconds` 와 `backoffLimit` 이 충돌하면 `activeDeadlineSeconds` 가 우선합니다 —
시간이 지나면 재시도가 남아 있어도 `reason: DeadlineExceeded` 로 종료됩니다.

## 검증

```bash
kubectl -n batch get jobs
# NAME     STATUS     COMPLETIONS   DURATION
# migrate  Complete   4/4           ~15s
# broken   Failed     0/1

kubectl -n batch get pods -l job-name=broken --no-headers | wc -l      # 3
kubectl -n batch get job broken -o jsonpath='{.status.conditions[*].reason}{"\n"}'
# BackoffLimitExceeded

kubectl -n batch logs job/report-manual        # date 출력 + "report"

kubectl -n batch get cronjob report
# NAME    SCHEDULE      TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE
# report  */5 * * * *   <none>     True      0
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CronJob을 즉시 돌리려면 `kubectl create job <이름> --from=cronjob/<크론잡>`.
- **헷갈리는 지점**: `completions` 는 총 몇 번 성공해야 하는지, `parallelism` 은 동시에 몇 개까지
  돌릴지입니다. `backoffLimit` 은 남은 실패 허용 **횟수**이지 파드 수가 아닙니다 (파드는 +1개).
  그리고 Job 파드의 `restartPolicy` 에 `Always` 를 쓰면 API 서버가 거부합니다 — Deployment yaml을
  베껴 쓸 때 자주 걸립니다.

## 참고 문서

- 검색어: `jobs run to completion`
- https://kubernetes.io/docs/concepts/workloads/controllers/job/
- https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
