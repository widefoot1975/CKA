# q12 — Share a scratch volume between containers

| Item | Value |
|---|---|
| Exam | mock_exam_e |
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
# 0) 이전 실습 흔적 정리 (tmp 네임스페이스는 이 문제만 쓴다)
kubectl delete ns tmp --ignore-not-found --wait=true

# 1) 문제에서 "이미 있다"고 한 네임스페이스 tmp
kubectl create ns tmp

# 2) 시작 상태 확인: tmp 는 Active, cache-pod 는 없음
kubectl get ns tmp
kubectl -n tmp get pods
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후에는 빈 네임스페이스 `tmp` 만 있다. Pod `cache-pod` 와 emptyDir 볼륨은 문제에서 직접 만든다.
`tmp` 네임스페이스는 다른 문제와 겹치지 않으므로 `cleanup.sh` 는 네임스페이스째 지운다(그 안의 `cache-pod` 도 함께 사라진다).

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns tmp --ignore-not-found --wait=true
```

</details>

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

---

Solution → **[solution.md](solution.md)**
