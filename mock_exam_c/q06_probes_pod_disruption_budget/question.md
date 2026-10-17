# q06 — Probes and a PodDisruptionBudget

| Item | Value |
|---|---|
| Exam | mock_exam_c |
| Domain | Workloads & Scheduling (15%) |
| Points | 5 |
| Host | `ssh k8s-c1` |
| Target time | 5 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.
A08·A15 도 `shop` 에 Deployment `api` 를 만들므로 세 문제를 동시에 펼쳐 두지 않는다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기**

```bash
# 0) 이전 실습 흔적 정리 — shop 은 다른 문제도 쓰는 namespace 라 이 문제의 리소스만 지운다
kubectl -n shop delete deploy api --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n shop delete svc api --ignore-not-found 2>/dev/null || true
kubectl -n shop delete pdb api-pdb --ignore-not-found 2>/dev/null || true

# 1) 지금 이미 cordon 된 노드를 적어 둔다 (cleanup.sh 가 6번에서 drain 한 노드만 uncordon 하도록)
kubectl get nodes -o jsonpath='{range .items[?(@.spec.unschedulable==true)]}{.metadata.name}{"\n"}{end}' \
  > /tmp/cka-c06-precordoned.txt

# 2) namespace + Deployment api (프로브 없음) + Service api
kubectl create ns shop --dry-run=client -o yaml | kubectl apply -f -
kubectl -n shop create deployment api --image=nginx:1.27 --replicas=3 --port=80
kubectl -n shop expose deployment api --port=80 --target-port=80
kubectl -n shop rollout status deploy api --timeout=180s

# 3) 설정 확인: 파드 3개 Running, 어느 노드에 몇 개 있는지
kubectl -n shop get deploy,svc,pdb
kubectl -n shop get pods -l app=api -o wide
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 직후 `shop` 에 프로브가 없는 Deployment `api`(파드 3개 `1/1 Running`)와 Service `api` 가 있고, PDB 는 아직 없다.
스케줄 가능한 워커 노드가 2개 이상이어야 6번 drain 이 끝난다. 파드가 노드마다 1개씩 퍼졌다면 6번은 `api` 파드가 가장 많은 노드로 한다.
`shop` 은 다른 문제도 쓰는 namespace 라 setup·cleanup 은 이 문제의 리소스(`api`, `api-pdb`)만 지우고, cleanup 은 namespace 가 비었을 때만 지운다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
# 6번에서 drain 한 노드 되돌리기 (예: worker01)
kubectl uncordon worker01
kubectl -n shop delete pdb api-pdb --ignore-not-found
kubectl -n shop delete svc api --ignore-not-found
kubectl -n shop delete deploy api --ignore-not-found
```

</details>

## Task

Namespace `shop` contains Deployment `api` with 3 replicas of `nginx:1.27`, labelled
`app=api`, serving on port 80.

1. Add a startup probe: HTTP GET `/` on port 80, allowed up to 60 seconds to come up,
   probing every 5 seconds.
2. Add a readiness probe: HTTP GET `/healthz` on port 80, every 5 seconds,
   `failureThreshold: 2`.
3. Add a liveness probe: TCP socket on port 80, `periodSeconds: 10`,
   `failureThreshold: 3`.
4. Create a PodDisruptionBudget `api-pdb` for `app=api` that keeps at least 2 pods
   available.
5. `/healthz` does not exist on the nginx image, so readiness will fail. Show what happens
   to the rollout and to the Service `api` endpoints, then make readiness pass by pointing
   the probe at a path that exists and let the rollout finish.
6. Attempt `kubectl drain` on the node holding two `api` pods and report what the PDB does.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
