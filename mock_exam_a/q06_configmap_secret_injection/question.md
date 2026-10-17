# q06 — Configure an application with a ConfigMap and Secret

| Item | Value |
|---|---|
| Exam | mock_exam_a |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 스크립트로 환경을 만든다. 여러 번 실행해도 안전하다.

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_a/q06_configmap_secret_injection
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 ConfigMap·Secret·Pod 를 모두 직접 만드는 것부터 시작하므로, setup 은 빈 namespace `web` 을 준비하고
nginx 이미지를 받을 수 있는지만 확인한다. 설정 직후 `web` 에는 이 문제의 오브젝트(`web-app`, `app-config`, `app-files`, `db-cred`)가 하나도 없다.

`web` 은 mock_exam_a/q09, mock_exam_b/q05, mock_exam_f/q06 도 쓰는 namespace 다. 특히 f06 도 `app-config` 를 만들므로
두 문제를 동시에 풀지 않는다. 정리할 때는 이 문제의 오브젝트만 지우고, `web` 이 비었을 때만 namespace 를 지운다.

## Task

An application in namespace `web` takes its settings from the cluster, not from its image.

1. Create a ConfigMap `app-config` with `APP_MODE=production` and `LOG_LEVEL=warn`.
2. Create a ConfigMap `app-files` with key `app.properties` = `timeout=30\nretries=3`.
3. Create a generic Secret `db-cred` with `username=appuser` and `password=S3cr3t!`.
4. Create a Pod `web-app` running `nginx:1.27` that
   - receives every key of `app-config` as an environment variable in one block
   - receives only the `password` key of `db-cred` as the variable `DB_PASSWORD`
   - mounts `db-cred` read-only at `/etc/db`
   - mounts `app.properties` at `/etc/nginx/app.properties` without hiding the image's own
     files in `/etc/nginx`
5. Show the variables and the mounted files from inside the container, and state in one
   line why the `/etc/nginx/app.properties` mount will not see a later edit of `app-files`.

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

[↑ 문항 목록](../README.md) · [← q05](../q05_deployment_rollout_rollback/question.md) · [q07 →](../q07_taint_toleration_affinity/question.md)
