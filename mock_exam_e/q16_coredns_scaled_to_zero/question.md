# q16 — Cluster DNS stopped working

| Item | Value |
|---|---|
| Exam | mock_exam_e |
| Domain | Troubleshooting (30%) |
| Points | 6 |
| Host | `ssh k8s-c1` |
| Target time | 8 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (트러블슈팅 문제라 명령어에 답이 보인다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

<details><summary>설정 명령 펼치기 (답 포함)</summary>

```bash
# 0) 이전 실습 결과 파일 정리
rm -rf /opt/course/e16

# 1) 장애 만들기 (내용은 풀이에서 확인)
kubectl -n kube-system scale deploy coredns --replicas=0
kubectl -n kube-system wait pod -l k8s-app=kube-dns --for=delete --timeout=120s 2>/dev/null || true

# 2) 시작 상태 확인: Service kube-dns 는 그대로 있다
kubectl -n kube-system get svc kube-dns
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정이 끝나면 **클러스터의 모든 파드가 DNS 이름을 해석하지 못한다.** 다른 문제의 확인 단계에서 Service 이름(예: `http://payments`)을 쓰면 이 문제를 풀기 전까지 실패한다.
실습이 끝나면 **반드시 `cleanup.sh`** 로 CoreDNS 를 kubeadm 기본값인 2개로 되돌린다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
kubectl -n kube-system scale deploy coredns --replicas=2
kubectl -n kube-system rollout status deploy coredns --timeout=120s
rm -rf /opt/course/e16
```

</details>

## Task

In cluster `k8s-c1`, pods can no longer resolve any DNS name, not even `kubernetes.default`.
Connections to pod IP addresses still work.

1. Find out why cluster DNS does not answer. Start from Service `kube-dns` in namespace
   `kube-system` and its EndpointSlice.
2. Fix the problem so that cluster DNS runs with `2` replicas again.
3. Write the kind and name of the object you had to fix, in the form `<kind>/<name>` (for example
   `daemonset/foo`), to `/opt/course/e16/cause.txt`.
4. From a temporary `busybox:1.36` pod, confirm that
   `nslookup kubernetes.default.svc.cluster.local` succeeds.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
