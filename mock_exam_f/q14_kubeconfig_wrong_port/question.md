# q14 — kubectl cannot reach the API server

| Item | Value |
|---|---|
| Exam | mock_exam_f |
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
KC=$HOME/.kube/config
ORIG=$HOME/.kube/config.f14.orig
[ -z "${KUBECONFIG:-}" ] || echo "주의: KUBECONFIG=$KUBECONFIG 가 설정되어 있습니다. 이 문제는 ~/.kube/config 를 씁니다 (unset KUBECONFIG)"

# 0) 처음 실행할 때 원본 kubeconfig 를 보관하고, 그다음부터는 원본으로 되돌린다
if [ -f "$ORIG" ]; then cp -p "$ORIG" "$KC"; else cp -p "$KC" "$ORIG"; fi
rm -rf /opt/course/f14

# 1) 장애 만들기: 현재 클러스터의 server 주소에서 포트만 6444 로 바꾼다
CL=$(kubectl --kubeconfig "$KC" config view --minify -o jsonpath='{.clusters[0].name}')
SERVER=$(kubectl --kubeconfig "$KC" config view --minify -o jsonpath='{.clusters[0].cluster.server}')
kubectl --kubeconfig "$KC" config set-cluster "$CL" --server="$(echo "$SERVER" | sed -E 's#:[0-9]+$##'):6444" >/dev/null

# 2) 시작 상태 확인: kubectl 이 connection refused 로 실패해야 한다
kubectl get nodes --request-timeout=5s || echo "kubectl 실패 (정상)"
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

처음 실행할 때 `~/.kube/config` 를 `~/.kube/config.f14.orig` 로 보관하고, 다시 실행하면 그 원본에서 시작한다. 설정이 끝나면 `k8s-c1` 의 `kubectl` 이 전부 실패한다.
오류 메시지의 주소는 지금 kubeconfig 의 server 주소를 따른다. 실습 클러스터의 server 가 `cp01` 이 아니라 IP 라면 `cp01:6444` 대신 그 IP 가 보이고, 1번의 `curl` 도 그 주소로 하면 된다.
**다른 문제의 setup 을 먼저 모두 실행하고 이것을 마지막에 실행한다.** 이 문제를 풀기 전에는 다른 문제도 kubectl 을 쓸 수 없다. 실습이 끝나면 `cleanup.sh` 로 원본을 되돌린다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
ORIG=$HOME/.kube/config.f14.orig
if [ -f "$ORIG" ]; then mv "$ORIG" "$HOME/.kube/config"; fi
rm -rf /opt/course/f14
kubectl get nodes
```

</details>

## Task

On `k8s-c1`, every `kubectl` command fails, for example:

```
$ kubectl get nodes
The connection to the server cp01:6444 was refused - did you specify the right host or port?
```

The API server itself is running normally on `cp01`, port `6443`. `kubectl` on `k8s-c1`
uses the kubeconfig file `~/.kube/config`.

1. Without using `kubectl`, show that the API server answers on `https://cp01:6443/livez`.
2. Write the wrong server URL that is currently configured in `~/.kube/config` to
   `/opt/course/f14/cause.txt`.
3. Fix `~/.kube/config` so that `kubectl get nodes` works again.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
