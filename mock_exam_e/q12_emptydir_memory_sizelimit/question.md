# q12 — Share a scratch volume between containers

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Storage (10%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_e/q12_emptydir_memory_sizelimit
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후에는 빈 네임스페이스 `tmp` 만 있다. Pod `cache-pod` 와 emptyDir 볼륨은 문제에서 직접 만든다.
`tmp` 네임스페이스는 다른 문제와 겹치지 않으므로 `cleanup.sh` 는 네임스페이스째 지운다(그 안의 `cache-pod` 도 함께 사라진다).

## Task

Namespace `tmp` already exists. Create a Pod named `cache-pod` in namespace `tmp` whose two
containers share a scratch volume.

1. Container `producer`: image `busybox:1.36`, command
   `sh -c 'echo hello > /cache/data; sleep 3600'`.
2. Container `consumer`: image `busybox:1.36`, command `sleep 3600`.
3. Both containers mount an `emptyDir` volume named `cache` at `/cache`. The volume must be backed
   by memory (tmpfs) and limited to `64Mi`.
4. Confirm that `consumer` can read `/cache/data` and that `/cache` is a tmpfs mount inside it.

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

[↑ 문항 목록](../README.md) · [← q11](../q11_retained_pv_reuse/question.md) · [q13 →](../q13_apiserver_wrong_etcd_endpoint/question.md)
