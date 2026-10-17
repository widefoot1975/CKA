# q12 — Combine a Secret, a ConfigMap and pod labels in one volume

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Storage (10%) |
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
kubectl create ns proj --dry-run=client -o yaml | kubectl apply -f -
kubectl -n proj delete pod projected-demo --ignore-not-found --wait=true
kubectl -n proj delete secret db-cred --ignore-not-found
kubectl -n proj delete cm app-cfg --ignore-not-found

# 1) Secret db-cred (키 password) 와 ConfigMap app-cfg (키 app.conf)
kubectl -n proj create secret generic db-cred --from-literal=password='S3cr3t-pw'
kubectl -n proj create cm app-cfg --from-literal=app.conf='log_level=info'

# 2) 시작 상태 확인: Secret·ConfigMap 은 있고 파드 projected-demo 는 없음
kubectl -n proj get secret db-cred
kubectl -n proj get cm app-cfg -o jsonpath='{.data.app\.conf}{"\n"}'
kubectl -n proj get pod projected-demo --ignore-not-found
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `proj` 에는 Secret `db-cred`(키 `password`, 값 `S3cr3t-pw`)와 ConfigMap `app-cfg`(키 `app.conf`, 값 `log_level=info`)가 있고 파드 `projected-demo` 는 없다. 파드는 문제에서 직접 만든다.
`proj` 는 D10 과 같은 namespace 라서 setup·cleanup 모두 namespace 를 통째로 지우지 않고 이 문제의 Secret·ConfigMap·파드만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n proj delete pod projected-demo --ignore-not-found
kubectl -n proj delete secret db-cred --ignore-not-found
kubectl -n proj delete cm app-cfg --ignore-not-found
```

</details>

## Task

Namespace `proj` contains Secret `db-cred` with key `password` and ConfigMap `app-cfg`
with key `app.conf`.

1. Create Pod `projected-demo` in namespace `proj` with label `app=demo`, image
   `busybox:1.36` and command `sleep 3600`.
2. Mount a single `projected` volume read-only at `/etc/app` in that Pod. It must provide:
   - key `password` of Secret `db-cred` as `/etc/app/password`
   - key `app.conf` of ConfigMap `app-cfg` as `/etc/app/app.conf`
   - the Pod's labels (Downward API field `metadata.labels`) as `/etc/app/labels`
3. Verify with `ls` and `cat` inside the Pod that all three files exist and contain the
   expected data.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
