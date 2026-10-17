# q13 — Node NotReady after a kubelet config change

| Item | Value |
|---|---|
| Exam | mock_exam_f |
| Domain | Troubleshooting (30%) |
| Points | 7 |
| Host | `ssh k8s-c1` → `ssh worker02`, then `sudo -i` |
| Target time | 9 min |
| Actual time |  |
| Result | ☐ correct ☐ partial ☐ wrong |

## Setup — 사전 환경 설정

문제를 풀기 전에 `k8s-c1` 에서 아래 둘 중 하나로 환경을 만든다. 여러 번 실행해도 안전하다.

**방법 A — 이 페이지의 명령어를 복사해서 붙여 넣기** (트러블슈팅 문제라 명령어에 답이 보인다. 미리 보고 싶지 않으면 방법 B 를 쓴다)

<details><summary>설정 명령 펼치기 (답 포함)</summary>

```bash
NODE=${NODE:-worker02}
kubectl get node "$NODE" >/dev/null
ssh "$NODE" true

# 0~1) worker02 에서: 처음 실행할 때 원본 설정을 보관하고, 그다음부터는 원본으로 되돌린 뒤 장애를 만든다
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
CFG=/var/lib/kubelet/config.yaml
FLAGS=/var/lib/kubelet/kubeadm-flags.env
for f in "$CFG" "$FLAGS"; do
  [ -f "$f" ] || continue
  if [ -f "$f.f13.orig" ]; then cp -p "$f.f13.orig" "$f"; else cp -p "$f" "$f.f13.orig"; fi
done
rm -rf /opt/course/f13

# 런타임 엔드포인트를 플래그로 주고 있으면 플래그가 config.yaml 보다 우선하므로 플래그를 뺀다
if [ -f "$FLAGS" ]; then
  sed -i -E 's#--container-runtime-endpoint=[^ "]+ ?##' "$FLAGS"
fi
if grep -q '^containerRuntimeEndpoint:' "$CFG"; then
  sed -i -E 's#^containerRuntimeEndpoint:.*#containerRuntimeEndpoint: unix:///run/containerd/containerd.sok#' "$CFG"
else
  echo 'containerRuntimeEndpoint: unix:///run/containerd/containerd.sok' >> "$CFG"
fi
systemctl restart kubelet || true
REMOTE

# 2) 시작 상태 확인: 노드가 NotReady(Ready=Unknown/False) 가 될 때까지 최대 2분 기다린다
for i in $(seq 1 24); do
  st=$(kubectl get node "$NODE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
  [ "$st" != "True" ] && break
  sleep 5
done
kubectl get nodes
```

</details>

**방법 B — 스크립트로 실행** · 파일: **[setup.sh](setup.sh)** / **[cleanup.sh](cleanup.sh)**

```bash
bash setup.sh      # 환경 만들기
bash cleanup.sh    # 실습 후 정리
```

`k8s-c1` 에서 실행하지만 실제 변경은 `ssh worker02` 로 노드에서 한다. 그래서 `k8s-c1` → `worker02` ssh 와 `worker02` 의 암호 없는 `sudo` 가 필요하다.
처음 실행할 때 `worker02` 의 `/var/lib/kubelet/config.yaml`(과 `kubeadm-flags.env`)을 `*.f13.orig` 로 보관하고, 다시 실행하면 그 원본에서 시작한다. 설정이 끝나면 `worker02` 가 `NotReady` 가 된다(최대 2분 기다린다).
실습이 끝나면 **반드시 `cleanup.sh`** 로 원본 설정을 되돌린다. 문제를 제대로 풀었어도 보관 파일 정리를 위해 실행한다.

<details><summary>정리 명령 (방법 A)</summary>

```bash
NODE=${NODE:-worker02}
ssh "$NODE" sudo bash -s <<'REMOTE'
set -euo pipefail
for f in /var/lib/kubelet/config.yaml /var/lib/kubelet/kubeadm-flags.env; do
  if [ -f "$f.f13.orig" ]; then cp -p "$f.f13.orig" "$f"; rm -f "$f.f13.orig"; fi
done
rm -rf /opt/course/f13
systemctl restart kubelet
REMOTE
kubectl wait node "$NODE" --for=condition=Ready --timeout=120s
```

</details>

## Task

Node `worker02` became `NotReady` shortly after someone edited the kubelet configuration
file `/var/lib/kubelet/config.yaml` on that node. containerd on `worker02` is running
normally.

1. On `worker02`, find out why the kubelet does not stay running. Write the wrong
   configuration value you found to `/opt/course/f13/cause.txt` on `worker02`.
2. Fix the configuration and restart the kubelet.
3. Confirm from `k8s-c1` that `worker02` is `Ready`.

## My attempt

```bash

```

---

Solution → **[solution.md](solution.md)**
