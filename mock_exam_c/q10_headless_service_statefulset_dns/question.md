# q10 — Headless Service and StatefulSet pod DNS

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `data` 는 c11 · d12 와 같이 쓰므로, 정리할 때 namespace 를 통째로 지우지 않고 이 문제의 리소스만 지운다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_c/q10_headless_service_statefulset_dns
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 namespace `data` 에는 `db` StatefulSet 과 `db` / `db-rw` Service 가 없다. 이 문제는 모두 직접 만드는 문제라 미리 만들어 두는 리소스는 없다.
이미지 `nginx:1.27`, `busybox:1.36` 을 받을 수 있어야 한다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q09](../q09_ingress_to_gateway_migration/question.md) · [q11 →](../q11_volumeclaimtemplates_statefulset/question.md)
