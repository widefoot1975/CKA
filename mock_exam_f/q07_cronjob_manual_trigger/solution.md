# q07 — Schedule and trigger a CronJob · 풀이

← 문제: **[question.md](question.md)**

## 문제 (해석)

네임스페이스 `ops` 는 이미 있다.

1. 네임스페이스 `ops` 에 CronJob `cleanup` 을 만든다. image `busybox:1.36` 으로 명령
   `sh -c 'date; echo cleanup done'` 을 10분마다 실행한다. 히스토리에 성공한 Job `2` 개와 실패한 Job
   `1` 개를 남기고, 이전 실행이 아직 끝나지 않았으면 새 실행을 절대 시작하지 않아야 한다.
2. 스케줄을 기다리지 않고 CronJob 을 지금 바로 `cleanup-manual` 이라는 이름의 Job 으로 실행한다.
3. Job `cleanup-manual` 의 로그 출력을 `/opt/course/f07/run.log` 에 쓴다.

## 모범 풀이

**1) 뼈대는 명령으로, 나머지는 yaml 에 추가**

```bash
kubectl -n ops create cronjob cleanup --image=busybox:1.36 --schedule='*/10 * * * *' \
  --dry-run=client -o yaml -- sh -c 'date; echo cleanup done' > cleanup.yaml
vi cleanup.yaml          # spec 아래에 세 줄 추가
kubectl apply -f cleanup.yaml
```

**플래그는 반드시 `--` 앞에** 둡니다. `--` 뒤의 모든 것은 컨테이너 명령으로 들어가므로,
`-- sh -c '...' --dry-run=client -o yaml` 처럼 쓰면 `--dry-run` 까지 명령의 인자가 되고 CronJob 이 바로
만들어집니다. 히스토리 한도와 동시 실행 정책은 `create cronjob` 에 플래그가 없어서 yaml 로 넣습니다.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup
  namespace: ops
spec:
  schedule: '*/10 * * * *'
  concurrencyPolicy: Forbid          # 추가 — 이전 실행이 active 면 이번 실행을 건너뜀
  successfulJobsHistoryLimit: 2      # 추가 (기본 3)
  failedJobsHistoryLimit: 1          # 추가 (기본 1)
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: cleanup
            image: busybox:1.36
            command: ["sh", "-c", "date; echo cleanup done"]
```

| `concurrencyPolicy` | 이전 실행이 아직 돌고 있을 때 |
|---|---|
| `Allow` (기본) | 새 실행도 함께 시작 |
| `Forbid` | 새 실행을 건너뜀 |
| `Replace` | 이전 실행을 중지하고 새 실행으로 교체 |

**2~3) 지금 실행하고 로그 저장**

```bash
kubectl -n ops create job cleanup-manual --from=cronjob/cleanup
kubectl -n ops wait --for=condition=complete job/cleanup-manual --timeout=60s
mkdir -p /opt/course/f07
kubectl -n ops logs job/cleanup-manual > /opt/course/f07/run.log
```

`--from=cronjob/cleanup` 은 CronJob 의 `jobTemplate` 을 그대로 복사해 Job 을 즉시 만듭니다. 스케줄을
`* * * * *` 로 바꿔 기다리는 것보다 빠르고 CronJob 설정을 건드리지 않습니다.

## 검증

```bash
kubectl -n ops get cronjob cleanup          # SCHEDULE */10 * * * *, SUSPEND False
kubectl -n ops get cj cleanup -o jsonpath='{.spec.concurrencyPolicy} {.spec.successfulJobsHistoryLimit} {.spec.failedJobsHistoryLimit}{"\n"}'
# Forbid 2 1
kubectl -n ops get job cleanup-manual       # STATUS Complete, COMPLETIONS 1/1
cat /opt/course/f07/run.log
# Sat Sep 26 10:03:12 UTC 2026
# cleanup done
```

## 오답 원인 / 배운 점

- **왜 틀렸나**:
- **기억할 것**: CronJob 을 즉시 실행하려면 `kubectl create job <이름> --from=cronjob/<크론잡>`. `create cronjob` 의 플래그는 `--` 앞에 둔다.
- **헷갈리는 지점**: 수동으로 만든 Job 도 CronJob 을 owner 로 가지므로, 나중에 스케줄 실행이 쌓이면 히스토리 한도(성공 2개)에 따라 정리될 수 있습니다. 로그가 필요하면 바로 파일로 남깁니다. 그리고 CronJob 의 파드 템플릿에는 `restartPolicy: Always` 를 쓸 수 없습니다(`OnFailure` 또는 `Never`).

## 참고 문서

- 검색어: `cronjob`
- https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_job/

## 복습 기록

| 날짜 | 결과 | 메모 |
|---|---|---|
|  |  |  |
