# q09 — Restrict both ingress and egress with NetworkPolicy

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Services & Networking (20%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 7 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 (namespace 를 지우면 만들었던 NetworkPolicy 도 함께 지워진다)
kubectl delete ns payments frontend scanner --ignore-not-found --wait=true
kubectl create ns payments
kubectl create ns frontend
kubectl create ns scanner

# 1) 모든 파드에 netshoot 이미지 사용 (curl · nc · nslookup 이 다 들어 있음)
IMG=nicolaka/netshoot:v0.13

# payments: api 는 8080 HTTP, db 는 5432 TCP. --expose 로 같은 이름의 Service 도 만든다
kubectl -n payments run api --image=$IMG --labels=app=api --port=8080 --expose -- python3 -m http.server 8080
kubectl -n payments run db  --image=$IMG --labels=app=db  --port=5432 --expose -- nc -lk 5432

# frontend 의 web 과 scanner 의 probe 는 라벨이 같다 (app=web)
kubectl -n frontend run web  --image=$IMG --labels=app=web -- sleep 3600
kubectl -n scanner  run probe --image=$IMG --labels=app=web -- sleep 3600

kubectl -n payments wait pod --all --for=condition=Ready --timeout=180s
kubectl -n frontend wait pod web   --for=condition=Ready --timeout=180s
kubectl -n scanner  wait pod probe --for=condition=Ready --timeout=180s

# 2) 시작 상태 확인: 정책이 없어서 지금은 모두 닿는다
kubectl -n payments get pods,svc --show-labels
kubectl get ns frontend scanner --show-labels
kubectl -n payments get netpol
kubectl -n scanner exec probe -- curl -s -o /dev/null -w 'probe → api:8080 HTTP %{http_code}\n' --max-time 3 api.payments:8080
kubectl -n payments exec api -- nc -zv -w 3 db 5432
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `payments` 에는 파드·Service `api`(8080, HTTP)와 `db`(5432, TCP)가, `frontend` 에는 파드 `web` 이, `scanner` 에는 파드 `probe` 가 있다. `web` 과 `probe` 는 둘 다 라벨이 `app=web` 이다. NetworkPolicy 는 하나도 없어서 마지막 확인에서는 `probe` 도 `api` 에 닿고(HTTP 200) `api` 도 `db` 에 닿는다.
모든 파드는 `curl`·`nc`·`nslookup` 이 들어 있는 `nicolaka/netshoot:v0.13` 이미지를 쓴다(처음 받을 때 시간이 조금 걸린다). 정책을 만든 뒤 차단이 안 되면 CNI 가 NetworkPolicy 를 지원하지 않는 것이다(flannel 등). Calico·Cilium 같은 CNI 에서 풀어야 의미가 있다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns payments frontend scanner --ignore-not-found
```

</details>

## Task

Namespace `payments` holds pod `api` (label `app=api`, listening on `8080`) and pod `db`
(label `app=db`, listening on `5432`), exposed by Services `api` (port `8080`) and `db`
(port `5432`). Namespace `frontend` (label `kubernetes.io/metadata.name=frontend`) holds
pod `web` (label `app=web`). Namespace `scanner` holds pod `probe` (label `app=web`).

Lock `payments` down without changing any pod.

1. Create a policy named `default-deny-all` in `payments` that denies all ingress and all
   egress for every pod in the namespace.
2. Create a policy named `api-allow` in `payments` that allows ingress to `app=api` on
   TCP `8080` **only** from pods labelled `app=web` **in namespace `frontend`** — pod
   `probe` in `scanner` must stay blocked.
3. In the same policy, allow egress from `app=api` to `app=db` in `payments` on TCP `5432`,
   and allow DNS resolution for `app=api` (UDP and TCP `53` towards `kube-system`).
4. Create a policy named `db-allow` in `payments` that lets `app=db` accept TCP `5432`
   **only** from `app=api`.
5. Verify: `web` reaches `api:8080`, `probe` does not, `api` reaches `db:5432`, `api`
   resolves `db.payments.svc.cluster.local`, and `api` cannot reach anything else.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
