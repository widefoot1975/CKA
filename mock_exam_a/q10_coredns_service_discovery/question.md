# q10 — Service discovery with CoreDNS

| Item | Value |
|---|---|
| Exam | mock_exam_a |
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
#    (mock_exam_b/q10 도 alpha·beta 를 쓰므로 namespace 는 다른 리소스가 없을 때만 지운다)
for ns in alpha beta; do
  kubectl get ns "$ns" >/dev/null 2>&1 || continue
  kubectl -n "$ns" delete deploy/web svc/web pod/no-dns pod/dns --ignore-not-found --wait=true
  if [ -z "$(kubectl -n "$ns" get deploy,sts,ds,svc,pod,job,cronjob -o name 2>/dev/null)" ]; then
    kubectl delete ns "$ns" --wait=true
  else
    echo "namespace $ns 에 다른 문제의 리소스가 남아 있어 namespace 는 지우지 않음"
  fi
done

# 1) 노드가 nginx 와 DNS 디버그 이미지를 받을 수 있는지 미리 확인 (오프라인 실습 환경 대비)
kubectl run img-check --image=nginx:1.27 --restart=Never --rm -i --pod-running-timeout=2m -- nginx -v || \
  echo "nginx 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"
kubectl run img-check-dns --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 \
  --restart=Never --rm -i --pod-running-timeout=2m -- true || \
  echo "jessie-dnsutils 이미지를 받지 못함 — 레지스트리 접근을 먼저 확인할 것"

# 2) 시작 상태 확인: CoreDNS 가 Ready 이고 alpha·beta 에 web 이 없음
kubectl -n kube-system rollout status deploy coredns --timeout=120s
for ns in alpha beta; do
  kubectl -n "$ns" get deploy,svc web 2>/dev/null || echo "$ns/web 없음 (정상)"
done
```

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

이 문제는 1단계에서 namespace 와 Deployment·Service 를 직접 만드는 것부터 시작하므로, setup 은 이전 흔적을 지우고
nginx 와 DNS 디버그 이미지(`jessie-dnsutils`)를 받을 수 있는지, CoreDNS 가 동작하는지만 확인한다. CoreDNS 설정은 건드리지 않는다.
`mock_exam_b/q10` 도 `alpha`·`beta` namespace 를 쓰므로, setup 과 cleanup 은 이 문제가 만드는 `web`·`no-dns`·`dns` 만 지우고
namespace 는 그 안에 다른 리소스가 없을 때만 지운다. namespace 가 남아 있으면 1단계의 `kubectl create namespace` 는
`AlreadyExists` 로 끝나는데, 그대로 다음 명령을 이어 가면 된다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
for ns in alpha beta; do
  kubectl get ns "$ns" >/dev/null 2>&1 || continue
  kubectl -n "$ns" delete deploy/web svc/web pod/no-dns pod/dns --ignore-not-found
  if [ -z "$(kubectl -n "$ns" get deploy,sts,ds,svc,pod,job,cronjob -o name 2>/dev/null)" ]; then
    kubectl delete ns "$ns"
  else
    echo "namespace $ns 에 다른 문제의 리소스가 남아 있어 namespace 는 지우지 않음"
  fi
done
```

</details>

## Task

Two namespaces expose a Service of the same name and clients keep reaching the wrong one.

1. Create namespaces `alpha` and `beta`. In each, create a Deployment `web` running
   `nginx:1.27` and a ClusterIP Service `web` on port 80.
2. Report which Deployment provides cluster DNS in `kube-system`, which Service fronts it,
   and which ConfigMap holds its Corefile.
3. From a debug pod in `alpha`, resolve `web`, `web.beta`, `web.beta.svc.cluster.local` and
   `web.beta.cluster.local`. Record which one fails.
4. Print that pod's `/etc/resolv.conf` and explain why a bare `web` resolves to `alpha`.
5. Create a Pod `no-dns` in `alpha` that does not use cluster DNS at all, and show that
   `web` no longer resolves inside it.
6. Write the FQDN a client uses to reach one specific pod behind a headless Service.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
