# q14 — Diagnose a CrashLoopBackOff pod

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

이 문제는 **일부러 고장 낸 파드**에서 시작한다. `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

<details><summary>명령어 펼치기 — 고장 원인이 보이니 풀기 전에는 읽지 않는 것을 권장</summary>

```bash
# 0) 이전 실습 흔적 정리 — namespace dev 는 A04 도 쓰므로 지우지 않고 파드만 지운다
kubectl -n dev delete pod broken-app --ignore-not-found --wait=true 2>/dev/null || true
kubectl get ns dev >/dev/null 2>&1 || kubectl create ns dev

# 1) 고장 내기: 시작할 때 약 48MB 를 메모리에 올리는데 memory limit 이 32Mi 라 OOMKilled(137) 로 죽는다
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: broken-app
  namespace: dev
  labels:
    app: broken-app
spec:
  restartPolicy: Always
  containers:
  - name: app
    image: busybox:1.36
    command:
    - sh
    - -c
    - |
      echo "broken-app starting"
      echo "loading cache (48MB) ..."
      CACHE=$(head -c 50331648 /dev/zero | tr '\0' x)
      echo "cache loaded, serving"
      while true; do sleep 3600; done
    resources:
      requests:
        memory: 16Mi
      limits:
        memory: 32Mi
YAML

# 2) 한 번 이상 재시작할 때까지 기다린다 (그래야 lastState 와 --previous 로그가 생긴다)
for i in $(seq 1 60); do
  RC=$(kubectl -n dev get pod broken-app -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || true)
  [ "${RC:-0}" -ge 1 ] && break
  sleep 3
done

# 3) 설정 확인: STATUS 가 OOMKilled / CrashLoopBackOff, RESTARTS 1 이상
kubectl -n dev get pod broken-app
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `dev` 의 파드 `broken-app` 은 `OOMKilled` 또는 `CrashLoopBackOff` 이고 RESTARTS 가 1 이상이다. 그래서 `lastState` 와 `--previous` 로그가 이미 있다.
namespace `dev` 는 A04(jane 의 Role/RoleBinding) 도 쓰므로 setup 과 cleanup 은 namespace 를 지우지 않고 `broken-app` 파드만 다시 만들거나 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n dev delete pod broken-app --ignore-not-found
```

</details>

## Task

Pod `broken-app` in namespace `dev` is in `CrashLoopBackOff`.

1. Report its restart count, the last exit code and the termination reason of the failing
   container.
2. Read the output of the instance that crashed, not of the one currently starting.
3. From the exit code, name the most likely cause before changing anything.
4. Repair the pod so it stays `Running`.
5. For exit codes 0, 1, 127 and 137 write the usual cause, one line each.
6. State in one line how you distinguish `CrashLoopBackOff` from `ImagePullBackOff` without
   reading any logs.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
