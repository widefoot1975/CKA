# q12 — Combine a Secret, a ConfigMap and pod labels in one volume

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_f/q12_projected_volume
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `proj` 에는 Secret `db-cred`(키 `password`, 값 `S3cr3t-pw`)와 ConfigMap `app-cfg`(키 `app.conf`, 값 `log_level=info`)가 있고 파드 `projected-demo` 는 없다. 파드는 문제에서 직접 만든다.
`proj` 는 D10 과 같은 namespace 라서 setup·cleanup 모두 namespace 를 통째로 지우지 않고 이 문제의 Secret·ConfigMap·파드만 지운다.

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

## Record

<!-- One row per attempt. Score = points earned (0 … Points). The first row is the mock exam itself; later rows are reviews. -->

| Date | Time (min) | Score | Note |
|---|---|---|---|
|  |  |  |  |

---

Solution → **[solution.md](solution.md)**

[↑ 문항 목록](../README.md) · [← q11](../q11_pv_reclaim_policy_patch/question.md) · [q13 →](../q13_kubelet_wrong_runtime_endpoint/question.md)
