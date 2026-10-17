# q02 — Read-only pod access for a ServiceAccount

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Cluster Architecture, Installation & Configuration (25%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (ServiceAccount·Role·RoleBinding 도 네임스페이스와 함께 지워진다)
kubectl delete ns apps --ignore-not-found --wait=true
kubectl create ns apps

# 1) 로그를 읽어 볼 파드 하나: 5초마다 한 줄씩 출력
kubectl -n apps run logger --image=busybox:1.36 -- sh -c 'i=0; while true; do echo "tick $i"; i=$((i+1)); sleep 5; done'
kubectl -n apps wait pod logger --for=condition=Ready --timeout=120s

# 2) 시작 상태 확인: ServiceAccount 는 default 만, Role·RoleBinding 은 없어야 한다
kubectl -n apps get sa,role,rolebinding,pods
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `apps` 에는 5초마다 `tick N` 을 찍는 파드 `logger` 와 기본 ServiceAccount `default` 만 있다. `monitor`, `pod-reader`, `monitor-pod-reader` 는 없다.
`logger` 는 문제 4번에서 로그 권한을 확인할 때 쓴다(`kubectl -n apps logs logger --as=system:serviceaccount:apps:monitor`).

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns apps --ignore-not-found
```

</details>

## Task

A monitoring tool in namespace `apps` will run under its own ServiceAccount. It must be able to
read pods and their logs, and nothing else.

1. Create ServiceAccount `monitor` in namespace `apps`.
2. Create Role `pod-reader` in `apps` that allows the verbs `get`, `list` and `watch` on the
   resources `pods` and `pods/log`.
3. Bind the Role to the ServiceAccount with RoleBinding `monitor-pod-reader` in `apps`.
4. Using `kubectl auth can-i` while impersonating the ServiceAccount, confirm that it can list
   pods and read pod logs in `apps`, but cannot delete pods.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
