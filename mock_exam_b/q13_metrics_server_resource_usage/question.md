# q13 — Restore metrics-server and analyse resource usage

| Item | Value |
|---|---|
| Exam | mock_exam_b |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c1` |
| Target time | 9 min |

## Setup — 사전 환경 설정

이 문제는 **metrics-server 를 일부러 고장 낸 상태에서** 시작한다. `k8s-c1` 에서 아래 스크립트를 실행한다. 여러 번 실행해도 안전하다. 실습이 끝나면 반드시 정리(cleanup)해서 metrics-server 를 원래대로 돌려놓는다 (다른 문제의 `kubectl top`·HPA 가 쓴다).

**실행** · 스크립트: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

<details><summary>노드에 저장소가 없을 때 — 스크립트 두 개 내려받기</summary>

```bash
B=https://raw.githubusercontent.com/widefoot1975/CKA/main/mock_exam_b/q13_metrics_server_resource_usage
curl -fsSLO $B/setup.sh && curl -fsSLO $B/cleanup.sh
```

</details>

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

설정 후 1분 안에 `kubectl top nodes` 가 실패하고, `prod` 의 HPA `api` 는 `<unknown>` 을 보인다. `prod` 에는 deployment `api`(2 replicas, 컨테이너 `app`·`log-agent`)와 `cache` 가 있다. `/opt/q13/` 는 비어 있다.
`mock_exam_c/q14` 도 namespace `prod` 를 쓰므로 두 문제를 동시에 펼쳐 두지 않는다. 이 문제의 setup/cleanup 은 label `q13=b13` 이 붙은 리소스만 만들고 지운다.

<details><summary>setup 이 바꾸는 것 (스포일러)</summary>

metrics-server Deployment 의 args 에서 `--kubelet-insecure-tls` 를 뺀다. metrics-server 가 kubelet 의 자체 서명 serving 인증서를 검증하지 못해 수집에 실패하고, 파드가 Ready 가 되지 않아 APIService `v1beta1.metrics.k8s.io` 가 `False (MissingEndpoints)` 가 된다. 기존 Ready 파드가 남지 않도록 replicas 를 0 으로 내렸다가 1 로 올린다.
kubelet 인증서를 클러스터 CA 로 서명해 쓰는 클러스터(`serverTLSBootstrap: true`)에서는 고장이 재현되지 않으며, setup 이 마지막에 경고를 낸다. `cleanup.sh` 는 플래그를 다시 넣고 metrics-server 가 Ready 가 될 때까지 기다린다.

</details>

## Task

`kubectl top nodes` fails on this cluster. An HPA in namespace `prod` is stuck showing
`<unknown>` as a consequence.

1. Write the exact error `kubectl top nodes` prints to `/opt/q13/error.txt`.
2. Determine whether the fault is the APIService registration, the metrics-server pod, or
   the connection from metrics-server to the kubelets. Write which one, and the command
   that decided it, to `/opt/q13/cause.txt`.
3. Fix it so that `kubectl top nodes` and `kubectl top pods -A` both return numbers.
   Do not delete the metrics-server Deployment.
4. Write the name of the pod using the most memory in namespace `prod` to
   `/opt/q13/top-mem.txt`.
5. For deployment `api` in `prod`, write the per-container CPU usage to
   `/opt/q13/api-containers.txt`.

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

[↑ 문항 목록](../README.md) · [← q12](../q12_csi_driver_volumemode/question.md) · [q14 →](../q14_gateway_traffic_not_routed/question.md)
