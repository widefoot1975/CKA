# q07 — Schedule and trigger a CronJob

| Item | Value |
|---|---|
| Exam | mock_exam_f |
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
# 0) 이전 실습 흔적 정리 (CronJob cleanup, Job cleanup-manual, 로그 파일)
kubectl delete ns ops --ignore-not-found --wait=true
rm -rf /opt/course/f07

# 1) 문제에서 "이미 있다"고 가정하는 namespace
kubectl create ns ops

# 2) 로그 파일을 쓸 디렉터리
mkdir -p /opt/course/f07

# 3) 설정 확인: ops 는 비어 있어야 함
kubectl get ns ops
kubectl -n ops get cronjob,job
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `ops` 는 비어 있고(`No resources found`), `/opt/course/f07/` 디렉터리가 있다.
CronJob 은 10분마다 Job 을 만들므로 실습이 끝나면 정리한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns ops --ignore-not-found
rm -rf /opt/course/f07
```

</details>

## Task

Namespace `ops` already exists.

1. Create CronJob `cleanup` in namespace `ops` that runs image `busybox:1.36` with the
   command `sh -c 'date; echo cleanup done'` every 10 minutes. It must keep `2` successful
   and `1` failed Job in its history, and it must never start a new run while the
   previous run is still active.
2. Without waiting for the schedule, run the CronJob now as a Job named `cleanup-manual`.
3. Write the log output of Job `cleanup-manual` to `/opt/course/f07/run.log`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
