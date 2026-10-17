# q10 — Verify pod-to-pod connectivity across namespaces

| Item | Value |
|---|---|
| Exam | mock_exam_b |
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
# 0) 이전 실습 흔적 정리 — 이 문제가 만드는 리소스만 지운다
#    (mock_exam_a/q10 도 alpha·beta 를 쓰므로 namespace 는 다른 리소스가 없을 때만 지운다)
kubectl -n alpha delete deploy/alpha-web svc/alpha-web --ignore-not-found --wait=true 2>/dev/null || true
kubectl -n beta  delete pod/probe --ignore-not-found --wait=true 2>/dev/null || true
for ns in alpha beta; do
  kubectl get ns "$ns" >/dev/null 2>&1 || continue
  if [ -z "$(kubectl -n "$ns" get deploy,sts,ds,svc,pod,job,cronjob -o name 2>/dev/null)" ]; then
    kubectl delete ns "$ns" --wait=true
  else
    echo "namespace $ns 에 다른 문제의 리소스가 남아 있어 namespace 는 지우지 않음"
  fi
done
rm -rf /opt/q10

# 1) 답안 파일 디렉터리 (namespace·Deployment·Service·파드는 문제에서 직접 만든다)
mkdir -p /opt/q10

# 2) 설정 확인: alpha-web 과 probe 가 없어야 함
kubectl -n alpha get deploy,svc alpha-web 2>/dev/null || echo "alpha/alpha-web 없음 (정상)"
kubectl -n beta  get pod probe 2>/dev/null           || echo "beta/probe 없음 (정상)"
ls -ld /opt/q10
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

namespace·Deployment·Service·파드는 문제 1·2번에서 직접 만들어야 하므로 setup 은 지난 실습의 `alpha-web`·`probe` 를 지우고 답안 디렉터리 `/opt/q10/` 만 만든다.
`mock_exam_a/q10` 도 namespace `alpha`·`beta` 를 쓴다. 그 문제의 리소스가 남아 있으면 namespace 는 지우지 않고 그대로 두므로, 1번의 `kubectl create namespace` 가 `AlreadyExists` 를 내도 그대로 진행하면 된다.
NetworkPolicy 를 쓰지 않는 문제라 CNI 종류와 상관없이 풀 수 있다. 단, `alpha`·`beta` 에 다른 실습의 NetworkPolicy 가 남아 있으면 4번의 HTTP 요청이 막힌다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n alpha delete deploy/alpha-web svc/alpha-web --ignore-not-found 2>/dev/null || true
kubectl -n beta  delete pod/probe --ignore-not-found 2>/dev/null || true
for ns in alpha beta; do
  kubectl get ns "$ns" >/dev/null 2>&1 || continue
  if [ -z "$(kubectl -n "$ns" get deploy,sts,ds,svc,pod,job,cronjob -o name 2>/dev/null)" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 문제의 리소스가 남아 있어 namespace 는 지우지 않음"
  fi
done
rm -rf /opt/q10
```

</details>

## Task

A team claims pods in one namespace cannot talk to a service in another. Prove or
disprove it.

1. In namespace `alpha`, create deployment `alpha-web` (`nginx:1.27`, 2 replicas) and
   expose it as a ClusterIP service `alpha-web` on port `80`.
2. In namespace `beta`, create a long-running pod named `probe` using image
   `busybox:1.36` that does not restart.
3. From `probe`, resolve `alpha-web` using its **short name** and then its FQDN. Write
   both results and the resolved ClusterIP to `/opt/q10/dns.txt`.
4. Write the pod IPs currently backing the service, read from the EndpointSlice, to
   `/opt/q10/endpoints.txt`, then show an HTTP request from `probe` actually succeeding.
5. Write to `/opt/q10/triage.txt` the one decisive command for each of the three layers
   that can break this: DNS, Service/EndpointSlice, NetworkPolicy.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
