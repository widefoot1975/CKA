# q10 — Headless Service and StatefulSet pod DNS

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `data` 는 c11 · d12 와 같이 쓰므로, 정리할 때 namespace 를 통째로 지우지 않고 이 문제의 리소스만 지운다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (이 문제가 만드는 것만)
kubectl -n data delete sts db --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n data delete svc db db-rw --ignore-not-found 2>/dev/null || true
kubectl -n data delete pod t v v2 --ignore-not-found 2>/dev/null || true
rm -rf /opt/course/q10

# 1) namespace data 준비 (이미 있으면 그대로 쓴다)
kubectl get ns data >/dev/null 2>&1 || kubectl create ns data

# 2) 3번의 조회는 CoreDNS 가 떠 있어야 한다
kubectl -n kube-system wait pod -l k8s-app=kube-dns --for=condition=Ready --timeout=120s

# 3) 설정 확인: data 에 db / db-rw 가 없어야 한다
kubectl -n data get sts,svc
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `data` 에는 `db` StatefulSet 과 `db` / `db-rw` Service 가 없다. 이 문제는 모두 직접 만드는 문제라 미리 만들어 두는 리소스는 없다.
이미지 `nginx:1.27`, `busybox:1.36` 을 받을 수 있어야 한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n data delete sts db --ignore-not-found
kubectl -n data delete svc db db-rw --ignore-not-found
kubectl -n data delete pod t v v2 --ignore-not-found
rm -rf /opt/course/q10
# data 에 다른 문제의 리소스가 없을 때만:  kubectl delete ns data
```

</details>

## Task

In namespace `data`, build a stable per-pod addressing scheme.

1. Create a headless Service `db` selecting `app=db`, port 5432 named `pg`.
2. Create a StatefulSet `db` with 3 replicas of `nginx:1.27` (stand-in for the real
   database), labelled `app=db`, container port 5432, governed by the `db` Service.
3. From a temporary pod in the same namespace, resolve:
   - the Service name `db`
   - the individual pod `db-0`
   Record what each returns and how they differ.
4. Write the fully qualified DNS name of `db-2` into `/opt/course/q10/fqdn.txt`.
5. Create a second, normal ClusterIP Service `db-rw` on the same selector and port, and
   show how its DNS answer differs from the headless one.
6. Explain why `db-0` is resolvable but a Deployment's pods are not resolvable by name.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
