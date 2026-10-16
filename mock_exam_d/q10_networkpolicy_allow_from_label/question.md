# q10 — Allow traffic to a backend from one frontend only

| Item | Value |
|---|---|
| Exam | mock_exam_d |
| Domain | Services & Networking (20%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 6 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리
kubectl delete ns proj --ignore-not-found --wait=true
kubectl create ns proj

# 1) 파드 세 개: backend 는 8080 에서 HTTP 응답, frontend·other 는 busybox
kubectl -n proj run backend  --image=hashicorp/http-echo:1.0 --labels=app=backend --port=8080 -- -listen=:8080 -text=backend
kubectl -n proj run frontend --image=busybox:1.36 --labels=app=frontend -- sleep 3600
kubectl -n proj run other    --image=busybox:1.36 --labels=app=other    -- sleep 3600

# 2) 이미 있는 정책 deny-all (모든 파드의 ingress 차단) — kubectl create 로는 못 만들어서 이것만 YAML
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-all, namespace: proj}
spec:
  podSelector: {}
  policyTypes: [Ingress]
YAML

kubectl -n proj wait pod --all --for=condition=Ready --timeout=120s

# 3) 시작 상태 확인: frontend 에서도 backend 로 안 닿아야 함 (닿으면 CNI 가 NetworkPolicy 를 지원하지 않는 것)
kubectl -n proj get pods --show-labels
kubectl -n proj get netpol
BIP=$(kubectl -n proj get pod backend -o jsonpath='{.status.podIP}')
kubectl -n proj exec frontend -- wget -qO- -T 3 http://$BIP:8080 || echo "frontend → backend 막힘 (정상)"
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `proj` 에는 파드 `backend`(8080 에서 `backend` 문자열 응답), `frontend`, `other` 와 NetworkPolicy `deny-all` 이 있고 `allow-frontend` 는 없다.
마지막 확인에서 frontend 의 요청이 응답을 받으면 CNI 가 NetworkPolicy 를 지원하지 않는 것이다(flannel 등). 이 문제는 Calico·Cilium 같은 CNI 에서 풀어야 의미가 있다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl delete ns proj --ignore-not-found
```

</details>

## Task

Namespace `proj` contains three pods: `backend` (label `app=backend`, serves HTTP on port
`8080`), `frontend` (label `app=frontend`) and `other` (label `app=other`). `frontend` and
`other` run `busybox:1.36`. A NetworkPolicy `deny-all` already blocks all ingress traffic in the
namespace.

1. Create a NetworkPolicy `allow-frontend` in `proj` that applies to pods labelled `app=backend`.
2. It must allow ingress on TCP port `8080` only from pods labelled `app=frontend` in the same
   namespace. Do not modify or delete `deny-all`.
3. Verify that `frontend` can reach `backend` on port 8080 and that the same request from
   `other` times out.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
