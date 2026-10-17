# q09 — Choose the least permissive NetworkPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.
namespace `app` 은 C13·C17 도 쓰므로 namespace 는 지우지 않고 이 문제의 파드와 정책만 정리한다. `default-deny-ingress` 가 `app` 의 모든 파드를 막으므로 C13·C17 과 동시에 펼쳐 두지 않는다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q09_networkpolicy_least_permissive
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `app` 에는 파드 `backend`(8080 에서 `backend` 문자열 응답)와 `frontend`, NetworkPolicy `default-deny-ingress` 가 있다. `/opt/course/f09/` 에는 후보 `policy-a.yaml`·`policy-b.yaml`·`policy-c.yaml` 이 파일로만 있고 아무것도 적용되지 않았으며, `choice.txt` 는 없다.
마지막 확인에서 frontend 의 요청이 응답을 받으면 CNI 가 NetworkPolicy 를 지원하지 않는 것이다(flannel 등). 이 문제는 Calico·Cilium 같은 CNI 에서 풀어야 의미가 있다.

## Task

In namespace `app`, Pod `frontend` (label `app=frontend`, image `busybox:1.36`) must reach
Pod `backend` (label `app=backend`), which serves HTTP on TCP port `8080`. A default-deny
ingress NetworkPolicy already exists in `app` and currently blocks this traffic. Three
candidate policies are prepared in `/opt/course/f09/`: `policy-a.yaml`, `policy-b.yaml`
and `policy-c.yaml`.

1. Apply the one candidate that is the **least permissive** while still allowing
   `frontend` to reach `backend` on TCP port `8080`. Do not modify or delete the existing
   NetworkPolicies.
2. Write the file name of the policy you applied (for example `policy-x.yaml`) to
   `/opt/course/f09/choice.txt`.
3. Verify that `frontend` can now connect to `backend` on port `8080`.

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

[↑ 문항 목록](../README.md) · [← q08](../q08_ingress_to_httproute_simple/question.md) · [q10 →](../q10_coredns_hosts_entry/question.md)
