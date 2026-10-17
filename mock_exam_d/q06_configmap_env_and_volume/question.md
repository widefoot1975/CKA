# q06 — Inject a ConfigMap as an env var and a file

| Item | Value |
|---|---|
| Exam | mock_exam_d |
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
# 0) 이전 실습 흔적 정리 (ConfigMap app-settings, 파드 settings-demo 도 함께 지워진다)
kubectl delete ns cfg --ignore-not-found --wait=true

# 1) 빈 namespace cfg 만 만든다 — ConfigMap 과 파드는 문제에서 직접 만든다
kubectl create ns cfg

# 2) 시작 상태 확인: kube-root-ca.crt 외에 ConfigMap 이 없고 파드도 없어야 함
kubectl -n cfg get cm,pod
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `cfg` 는 비어 있다(자동으로 생기는 ConfigMap `kube-root-ca.crt` 만 있음).
`app-settings` 와 `settings-demo` 는 문제를 풀면서 만든다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns cfg --ignore-not-found
```

</details>

## Task

Namespace `cfg` exists. An application needs one setting as an environment variable and all
settings as files.

1. Create ConfigMap `app-settings` in `cfg` with the keys `MODE=prod` and `COLOR=blue`.
2. Create pod `settings-demo` in `cfg` (image `busybox:1.36`, command `sleep 3600`) that
   - receives the value of key `MODE` as environment variable `APP_MODE`, and
   - mounts the whole ConfigMap as a volume at `/etc/settings`.
3. Verify inside the pod that `APP_MODE` is `prod` and that the file `/etc/settings/COLOR`
   contains `blue`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
