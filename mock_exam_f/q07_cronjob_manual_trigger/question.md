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
kubectl -n ops delete cronjob cleanup --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n ops delete job cleanup-manual --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
rm -rf /opt/course/f07

# 1) 문제에서 "이미 있다"고 가정하는 namespace — 없을 때만 만들고, 이 실습이 만들었다는 표시를 남긴다
if ! kubectl get ns ops >/dev/null 2>&1; then
  kubectl create ns ops
  kubectl label ns ops cka-lab-f07=created --overwrite
fi

# 2) 로그 파일을 쓸 디렉터리
mkdir -p /opt/course/f07

# 3) 설정 확인: ops 에 CronJob·Job 이 없어야 함
kubectl get ns ops
kubectl -n ops get cronjob,job
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `ops` 에 CronJob·Job 이 없고(`No resources found`), `/opt/course/f07/` 디렉터리가 있다.
namespace `ops` 는 A11·A12 도 쓰므로 setup·cleanup 은 이 문제의 CronJob·Job 만 지우고, namespace 는 이 setup 이 만들었고 비어 있을 때만 지운다.
CronJob 은 10분마다 Job 을 만들므로 실습이 끝나면 정리한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n ops delete cronjob cleanup --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
kubectl -n ops delete job cleanup-manual --ignore-not-found --cascade=foreground --wait=true 2>/dev/null || true
rm -rf /opt/course/f07

# namespace 는 이 실습의 setup 이 만들었고(라벨 cka-lab-f07=created) 남은 리소스가 없을 때만 지운다
for ns in ops; do
  [ "$(kubectl get ns "$ns" -o jsonpath='{.metadata.labels.cka-lab-f07}' 2>/dev/null || true)" = "created" ] || continue
  left=$( { kubectl -n "$ns" get all,configmap,secret,ingress,pvc,networkpolicy -o name 2>/dev/null
            kubectl -n "$ns" get gateway,httproute -o name 2>/dev/null; } \
          | grep -v '^configmap/kube-root-ca.crt$' || true)
  if [ -z "$left" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 리소스가 남아 있어 namespace 는 지우지 않음:"
    echo "$left"
  fi
done
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
